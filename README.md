# Know what song’s playing without disrupting your workflow

If you always find yourself switching between Spotify and whatever you’re doing just to see what song started playing, now you don’t have to! Spotify Notifier subtly presents the song title, artist, album, and cover art in the corner of your screen whenever a new song starts. Especially useful for the radio junkies or those that enjoy exploring new albums or playlists (you know who you are!)

![Screen Recording 2022-03-25 at 03 36 13-2](https://user-images.githubusercontent.com/19882060/160114333-94712a3e-e341-48ce-8606-72a55730e7d6.gif)


## How to install
*Only available on macOS, since that’s what I use and know best*

- [Download the app to your computer](https://github.com/ryanmohta/spotify-notifier/files/8349422/Spotify.Notifier.app.zip)
- Move the app anywhere in your Applications folder
- Open the app and accept permission to send notifications (for obvious reasons) and, if prompted, permission to control Spotify (so the app knows when a song was changed)
- That’s it! The app will now automatically run in the background whenever Spotify is open.

### How to uninstall
- Just delete the Spotify Notifier app from the Applications folder! You may need to log out and back in for changes to take effect, since the app is loaded into memory when the user logs in.

## How it works (if you’re curious)
Spotify Notifier makes use of a relatively lesser-known macOS tool, *AppleScript*. It’s a scripting language built into macOS that lets users control system-level functionality, such as system preferences and the file system, with a relatively English-like syntax (fun fact: I made an AppleScript four years ago to automatically switch between light and dark mode at sunset and sunrise before Apple added it themself 🤓)
```applescript
# a sample AppleScript
tell application "Finder" to make new folder at desktop
```

Surprisingly, many Mac apps have AppleScript libraries that let you use AppleScript to control parts of their app! Even more surprisingly, Spotify happens to be one of them — here’s a snippet of their AppleScript library:
<img width="737" alt="Screen Shot 2022-03-25 at 02 07 56" src="https://user-images.githubusercontent.com/19882060/160090377-3614d160-2c77-4a5a-ae60-62ea5963a78d.png">

But why is this useful? Thankfully, *Swift allows you to execute arbitrary AppleScript code within your Mac app*, which meant within Spotify Notifier, I could repeatedly call a script to get specific properties of the currently playing track.

I wrote a helper function to do this, which took in a property and outputted the result:
```swift
func getPropertyOfCurrentTrack(property: String) -> String? {
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: "if application \"/Applications/Spotify.app\" is running then tell application \"/Applications/Spotify.app\" to get the \(property) of the current track") {
        let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
        return output.stringValue
    }
    return error?.description
}
```

Then, I could just call this function to get properties like the name, artist, and album using Spotify’s AppleScript library:
```swift
guard let name = getPropertyOfCurrentTrack(property: "name") else { return }
```

Well, more specifically every half second I check the ID of the currently playing song, and if it’s different than it was the last time I called the function, then I gather the rest of the properties and display the notification with it using the [`NSUserNotification`](https://developer.apple.com/documentation/foundation/nsusernotification) API.

***wait, but that API’s deprecated!!!!1!1!***

I know, but unfortunately I couldn’t get the newer [`User Notifications`](https://developer.apple.com/documentation/usernotifications) framework to display the cover art in the notification after weeks of trying :((( Hopefully Apple fixes this in the future though!

## How it _used_ to work (if you’re _extra_ curious)

Before I found out that AppleScript can do this so elegantly, I used a _very_ roundabout process to deliver the notification to the user’s computer. This process was unnecessarily clunky, slow, and needed to be updated regularly, but at the time I thought it was the only way so I rolled with it.

The project started out as a Safari extension that monitored the [open.spotify.com](https://open.spotify.com) website to check when the current song changed. It accomplished this using a [`MutationObserver`](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver) that literally checked the DOM tree, _continuously_, to see if the node corresponding to the current song changed:

```js
function onMutated(mutations) {
  mutations.forEach(mutation => {
    let title = document.querySelector(`${INNER_NODE} ${TITLE_NODE}`);
    let artist = document.querySelector(`${INNER_NODE} ${ARTIST_NODE}`);
    let albumCover = document.querySelector(`${INNER_NODE} ${ALBUM_COVER_NODE}`);

    if (title !== null && artist !== null && albumCover !== null) {
      // code run when the song changed
    }
  });
}
```

Then, I had to figure out a way for the extension to send the app a message that the song changed, while including data about the new song as a payload within the message. I knew that message passing between a Mac app and its corresponding Safari extension was possible since I use it for [Messenger Black](https://github.com/ryanmohta/messenger-black), but turns out you can’t pass a payload along with it since that violates App Sandbox rules.

To get around that, I made a _whole Express server_ for the sole purpose of pushing the current song from the extension, and pulling it from the app. This was probably the most overkill part of the process, but at least it taught me how to use Express and Heroku since it was my first time using them!

The code to post the current song from the extension:
```js
const data = {
  title: title.innerText,
  artist: artist.innerText,
  albumURL: albumCover.src
};

fetch(SERVER_URL + '/update', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data),
})
.then(() => safari.extension.dispatchMessage("Song Changed"));
```

On the Heroku server (using Express):
```js
var data = {};

app.post('/update', (req, res) => {
  data = req.body;
  res.sendStatus(200);
});

app.get('/latest', (req, res) => {
  res.json(data);
})
```

And getting the current song from the Swift app:
```swift
let url = URL(string: "https://spotify-notifier.herokuapp.com/latest")!

let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
    do {
        // stuff to send the notification with the newly acquired data
    } catch {
        print(error.localizedDescription)
    }
}
```

This approach worked, but with many minor annoyances:
- The Spotify Web Player had to be open for the app to work, and required a Spotify Premium account since you need a Premium account to play songs from the Web Player
- Spotify occasionally updated the Web Player, which meant I would have to update the HTML nodes to make sure they were still referencing the current song container
- The Heroku server would take several seconds to start up if unused for a while, which meant it would also take several seconds to receive the first notification after a while
  - Additionally, the Heroku server used up a good chunk of my Heroku account quota, which meant less dyno hours for my Discord bots and other things on my Heroku account

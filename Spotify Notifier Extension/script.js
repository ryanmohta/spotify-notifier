const SERVER_URL = 'https://spotifynotifier-server.herokuapp.com'

document.addEventListener("DOMContentLoaded", function(event) {
  setTimeout(() => {
    // Initial target inner node
    var innerObserver = new MutationObserver(onMutated);
    var targetNodeInner = document.querySelector('._116b05d7721c9dfb84bb69e8f4fc5e01-scss');
    var observerConfig = { attributes: true, childList: true, characterData: true };
    innerObserver.observe(targetNodeInner, observerConfig);

    var outerObserver = new MutationObserver((mutations) => {
      onMutated(mutations);
      var innerObserver = new MutationObserver(onMutated);
      var targetNodeInner = document.querySelector('._116b05d7721c9dfb84bb69e8f4fc5e01-scss');
      var observerConfig = { attributes: true, childList: true, characterData: true };
      innerObserver.observe(targetNodeInner, observerConfig);
    });

    var targetNodeOuter = document.querySelector('.b51affc9f26a5c8f65a387abdd375bef-scss');
    outerObserver.observe(targetNodeOuter, observerConfig);

  }, 5000);
});


function onMutated(mutations) {
  mutations.forEach(function(mutation) {
    let title = document.querySelector('._116b05d7721c9dfb84bb69e8f4fc5e01-scss ._3773b711ac57b50550c9f80366888eab-scss');
    let artist = document.querySelector('._116b05d7721c9dfb84bb69e8f4fc5e01-scss .b6d18e875efadd20e8d037931d535319-scss');
    let albumCover = document.querySelector('._116b05d7721c9dfb84bb69e8f4fc5e01-scss ._64acb0e26fe0d9dff68a0e9725b2a920-scss');

    if (title !== null && artist !== null && albumCover !== null) {
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
    }
  });
}

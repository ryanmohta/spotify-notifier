//
//  AppDelegate.swift
//  Spotify Notifier
//
//  Created by Ryan Mohta on 2/17/21.
//

import Cocoa
import UserNotifications
import ServiceManagement

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
//         Insert code here to initialize your application
        NSUserNotificationCenter.default.delegate = self
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkForSongChanged), userInfo: nil, repeats: true)
        
        let launcherAppId = "com.ryanmohta.Spotify-Notifier-Launcher"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty

        SMLoginItemSetEnabled(launcherAppId as CFString, true)

        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
            return true
    }
    
    var prevSongId: String = ""
    
    @objc func checkForSongChanged() {
        guard let songId: String = getPropertyOfCurrentTrack(property: "id") else { return }
        
        if songId != prevSongId {
            guard let name = getPropertyOfCurrentTrack(property: "name") else { return }
            guard let artist = getPropertyOfCurrentTrack(property: "artist") else { return }
            guard let album = getPropertyOfCurrentTrack(property: "album") else { return }
            guard let albumURLString = getPropertyOfCurrentTrack(property: "artwork url") else { return }
            
            guard let albumURL = URL(string: albumURLString) else { return }
            guard let albumImage = NSImage(contentsOf: albumURL) else { return }
            
            sendNotification(name: name, artist: artist, album: album, albumImage: albumImage)
            
            prevSongId = songId
        }
    }
    
    func getPropertyOfCurrentTrack(property: String) -> String? {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: "if application \"/Applications/Spotify.app\" is running then tell application \"/Applications/Spotify.app\" to get the \(property) of the current track") {
            let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
            return output.stringValue
        }
        return error?.description
    }
    
    func sendNotification(name: String, artist: String, album: String, albumImage: NSImage) -> Void {
        let notification = NSUserNotification()
        notification.identifier = UUID().uuidString
        notification.title = name
        notification.informativeText = "\(artist) • \(album)"
        notification.contentImage = albumImage
        NSUserNotificationCenter.default.deliver(notification)
    }

}

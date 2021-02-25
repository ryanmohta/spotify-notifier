//
//  AppDelegate.swift
//  Spotify Notifier
//
//  Created by Ryan Mohta on 2/17/21.
//

import Cocoa
import UserNotifications

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
//         Insert code here to initialize your application
        NSUserNotificationCenter.default.delegate = self

        DistributedNotificationCenter.default().addObserver(self, selector: #selector(notificationReceived), name: NSNotification.Name(rawValue: "Song Changed"), object: nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
            return true
    }
    
    @objc func notificationReceived(notification: NSNotification) {
        
        let url = URL(string: "https://localhost:8888/latest")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                print(String(data: data!, encoding: .utf8)!)
                let notification = NSUserNotification()
                notification.identifier = UUID().uuidString
                notification.title = json?["title"] as? String
                notification.informativeText = json?["artist"] as? String
                notification.contentImage = NSImage(contentsOf: URL(string: (json?["albumURL"] as? String)!)!)
                NSUserNotificationCenter.default.deliver(notification)
            } catch {
                print(error.localizedDescription)
            }
        }

        task.resume()
        
    }

}

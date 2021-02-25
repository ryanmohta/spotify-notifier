//
//  ViewController.swift
//  Spotify Notifier
//
//  Created by Ryan Mohta on 2/17/21.
//

import Cocoa
import SafariServices.SFSafariApplication
import SafariServices.SFSafariExtensionManager

let appName = "Spotify Notifier"
let extensionBundleIdentifier = "com.ryanmohta.Spotify-Notifier.Extension"

class ViewController: NSViewController {

    @IBOutlet var appNameLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appNameLabel.stringValue = appName
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { (state, error) in
            guard let state = state, error == nil else {
                // Insert code to inform the user that something went wrong.
                return
            }

            DispatchQueue.main.async {
                if (state.isEnabled) {
                    self.appNameLabel.stringValue = "\(appName)'s extension is currently on."
                } else {
                    self.appNameLabel.stringValue = "\(appName)'s extension is currently off. You can turn it on in Safari Extensions preferences."
                }
            }
        }
    }
    
    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { error in
            guard error == nil else {
                // Insert code to inform the user that something went wrong.
                return
            }

            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
    }
    @IBAction func notificationButton(_ sender: Any) {
            let notification = NSUserNotification()
            notification.identifier = UUID().uuidString
            notification.title = "Hello"
            notification.subtitle = "How are you?"
            notification.informativeText = "This is a test"
            notification.contentImage = NSImage(contentsOf: URL(string: "https://i.scdn.co/image/ab67616d0000485198f9f76ab2ae4525fc4e3d7a")!)
//            notification.deliveryDate = Date(timeIntervalSinceNow: 10)

            // Manually display the notification
//            NSUserNotificationCenter.default.scheduleNotification(notification)
            NSUserNotificationCenter.default.deliver(notification)
    }
    
}

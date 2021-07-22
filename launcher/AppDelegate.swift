//
//  AppDelegate.swift
//  Spotify Notifier Launcher
//
//  Created by Ryan Mohta on 6/24/21.
//

import Cocoa

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @objc func terminate() {
        NSApp.terminate(nil)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppIdentifier = "com.ryanmohta.Spotify-Notifier"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty

        if !isRunning {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.terminate), name: .killLauncher, object: mainAppIdentifier)

            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.removeLast()

            let newPath = NSString.path(withComponents: components)

            NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: newPath), configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
        else {
            self.terminate()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}


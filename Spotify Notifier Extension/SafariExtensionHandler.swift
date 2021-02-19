//
//  SafariExtensionHandler.swift
//  Spotify Notifier Extension
//
//  Created by Ryan Mohta on 2/17/21.
//

import SafariServices
import UserNotifications

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    func addAttachment(url: String) throws -> UNNotificationAttachment {
        let imageData = try? Data(contentsOf: URL(string: url)!)
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)

        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
        let imageFileIdentifier = UUID().uuidString
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
        
        try imageData!.write(to: fileURL)
        return try UNNotificationAttachment(identifier: temporaryFolderName, url: fileURL, options: nil)
    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
            
            let content = UNMutableNotificationContent()
            content.title = userInfo?["title"] as! String
            content.body = userInfo?["artist"] as! String
            
            do {
                let attachment = try self.addAttachment(url: userInfo?["albumCover"] as! String)
                content.attachments = [attachment]
            }
            catch {
                NSLog(error.localizedDescription)
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.25, repeats: false)
            
            // Create the request
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString,
                        content: content, trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil {
                NSLog("\(String(describing: error))")
               }
            }
        }
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}

//
//  SafariExtensionHandler.swift
//  Spotify Notifier Extension
//
//  Created by Ryan Mohta on 2/17/21.
//

import SafariServices
import UserNotifications

extension UNNotificationAttachment {

    static func create(url: String) -> UNNotificationAttachment? {
        
        let directoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                            isDirectory: true)
        
        let filename = ProcessInfo().globallyUniqueString
        let fileURL = URL(fileURLWithPath: filename, relativeTo: directoryURL).appendingPathExtension("jpeg")
        
        NSLog("\(fileURL.absoluteString)")
        
        do {
            let imageURL = URL(string: "https://beta.ryanmohta.com/static/media/profilePicture.0090412a.jpg")!
            let image = NSImage(data: try Data(contentsOf: imageURL))
            
            guard let tiffRep = image?.tiffRepresentation else { return nil }
            
            let bits = NSBitmapImageRep(data: tiffRep)
            NSLog("\(String(describing: bits))")
            let data = bits?.representation(using: .jpeg, properties: [:])
            NSLog("\(String(describing: data))")
            
            try data?.write(to: fileURL,
                           options: .atomic)
            
            let imageAttachment = try UNNotificationAttachment(identifier: filename, url: fileURL, options: nil)
            
            return imageAttachment
        } catch {
            NSLog("error " + error.localizedDescription)
        }
        return nil
    }
}

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
            
            let content = UNMutableNotificationContent()
            content.title = userInfo?["title"] as! String
            content.body = userInfo?["artist"] as! String
            
            if let attachment = UNNotificationAttachment.create(url: userInfo?["albumCover"] as! String) {
                NSLog("\(attachment)")
                // where myImage is any UIImage
                content.attachments = [attachment]
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

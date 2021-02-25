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
        let extendedURL = "https://localhost:8888/images/\(url).jpeg"
//        let extendedURL = "https://beta.ryanmohta.com/static/media/profilePicture.0090412a.jpg"
        let imageData = try? Data(contentsOf: URL(string: extendedURL)!)
        NSLog("1. imageData")
        NSLog("\(String(describing: imageData))")
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)
        NSLog("2. temporaryFolderURL")
        NSLog(temporaryFolderURL.absoluteString)
        
//        let fileURL = URL(fileURLWithPath: fileManager.currentDirectoryPath).appendingPathComponent("webserver/images/").appendingPathComponent(url).appendingPathExtension("jpeg")
        
//        let fileURL = Bundle.main.url(forResource: url, withExtension: "jpeg")
        
//        NSLog("absolute path of fileURL:")
//        NSLog(fileURL?.absoluteString ?? "url error")

        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
        
        // TEMPORARY
        let imageFileIdentifierTemp = UUID().uuidString
        let fileURLTemp = temporaryFolderURL.appendingPathComponent(imageFileIdentifierTemp).appendingPathExtension("jpeg")
        
        NSLog("2.5. fileURLTemp")
        NSLog(fileURLTemp.absoluteString)

        try imageData!.write(to: fileURLTemp)
        //
        
        let imageFileIdentifier = UUID().uuidString
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier).appendingPathExtension("jpeg")
        
        NSLog("3. fileURL")
        NSLog(fileURL.absoluteString)

        try imageData!.write(to: fileURL)
        
        let identifier = UUID().uuidString
        
        return try UNNotificationAttachment(identifier: identifier, url: fileURL, options: [UNNotificationAttachmentOptionsTypeHintKey: kUTTypeJPEG])
    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
            
            DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(rawValue: "Song Changed"), object: nil, userInfo: nil, deliverImmediately: true)
            
//            let notification = NSUserNotification()
//            notification.identifier = UUID().uuidString
//            notification.title = "Hello"
//            notification.subtitle = "How are you?"
//            notification.informativeText = "This is a test"
//            notification.contentImage = NSImage(contentsOf: URL(string: "https://placehold.it/300")!)
//            // Manually display the notification
////            NSUserNotificationCenter.default.scheduleNotification(notification)
//            NSUserNotificationCenter.default.deliver(notification)
            
//            let content = UNMutableNotificationContent()
//            content.title = userInfo?["title"] as! String
//            content.body = userInfo?["artist"] as! String

//            do {
//                let attachment = try self.addAttachment(url: userInfo?["albumCover"] as! String)
//                content.attachments = [attachment]
//            }
//            catch {
//                NSLog(error.localizedDescription)
//            }
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
//
//            // Create the request
//            let uuidString = UUID().uuidString
//            let request = UNNotificationRequest(identifier: uuidString,
//                        content: content, trigger: trigger)
//
//            // Schedule the request with the system.
//            let notificationCenter = UNUserNotificationCenter.current()
//            notificationCenter.add(request) { (error) in
//               if error != nil {
//                NSLog("\(String(describing: error))")
//               }
//            }
            
//            let content = UNMutableNotificationContent()
//            content.title = userInfo?["title"] as! String
//            content.body = userInfo?["artist"] as! String
//
//            let albumCover = userInfo?["albumCover"] as! String
//
//            if let url = URL(string: "https://localhost:8888/images/\(albumCover).jpeg") {
//
//                let pathExtension = url.pathExtension
//                NSLog("1. pathExtension")
//                NSLog(pathExtension)
//
//                let task = URLSession.shared.downloadTask(with: url) { (result, response, error) in
//                    if let result = result {
//
//                        NSLog("2. result")
//                        NSLog(result.absoluteString)
//
//                        let identifier = ProcessInfo.processInfo.globallyUniqueString
//                        let target = FileManager.default.temporaryDirectory.appendingPathComponent(identifier).appendingPathExtension(pathExtension)
//
//                        NSLog("3. target")
//                        NSLog(target.absoluteString)
//
//                        do {
//                            try FileManager.default.moveItem(at: result, to: target)
//                            NSLog("3. moveItem")
//
//                            let attachment = try UNNotificationAttachment(identifier: identifier, url: target, options: nil)
//                            content.attachments = [attachment]
//
//                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
//
//                            let notification = UNNotificationRequest(identifier: Date().description, content: content, trigger: trigger)
//
//                            UNUserNotificationCenter.current().add(notification, withCompletionHandler: { (error) in
//                                if let error = error {
//                                    NSLog(error.localizedDescription)
//                                }
//                            })
//
////                            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//
//                        }
//                        catch {
//                            NSLog(error.localizedDescription)
//                        }
//                    }
//                }
//                task.resume()
//            }
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

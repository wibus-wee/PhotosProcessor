//
//  SendNotification.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/17.
//

import UserNotifications

func sendNotification(title: String, body: String, delayInSeconds: TimeInterval) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    let category = UNNotificationCategory(identifier: "PhotosProcessor", actions: [], intentIdentifiers: [], options: [])
    // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delayInSeconds, repeats: false)
    let request = UNNotificationRequest(identifier: "PhotosProcessor", content: content, trigger: nil)
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.requestAuthorization(options: [.alert]) { (granted, error) in
        if let error = error {
            print("Error \(error.localizedDescription)")
        }
    }
    notificationCenter.setNotificationCategories([category])
    notificationCenter.getNotificationSettings { (settings) in
        if settings.authorizationStatus != .authorized {
            print("Notifications not allowed")
        }
    }
    notificationCenter.add(request) { (error) in
        if let error = error {
            print("Error \(error.localizedDescription)")
        }
    }
}

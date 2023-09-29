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
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delayInSeconds, repeats: false)
    let request = UNNotificationRequest(identifier: "PhotosProcessor", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

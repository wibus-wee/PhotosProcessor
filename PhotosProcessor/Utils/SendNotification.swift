//
//  SendNotification.swift
//  PhotosProcessor
//
//  Created by wibus on 2023/9/17.
//

import SwiftUI

// @wip
func sendNotification(title: String, subtitle: String, informativeText: String) {
    let notification = NSUserNotification()
    notification.title = title
    notification.subtitle = subtitle
    notification.informativeText = informativeText
    NSUserNotificationCenter.default.deliver(notification)
}
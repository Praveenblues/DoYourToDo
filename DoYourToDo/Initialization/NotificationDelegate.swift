//
//  NotificationDelegate.swift
//  DoYourToDo
//
//  Created by Praveen on 19/04/26.
//

import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner/list while app is in foreground
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle taps or actions
        let userInfo = response.notification.request.content.userInfo
        print("Tapped notification userInfo: \(userInfo)")
        completionHandler()
    }
}

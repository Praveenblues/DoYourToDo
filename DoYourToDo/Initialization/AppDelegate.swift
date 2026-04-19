//
//  AppDelegate.swift
//  DoYourToDo
//
//  Created by Praveen on 19/04/26.
//

import Firebase
import GoogleUtilities_AppDelegateSwizzler

class AppDelegate: NSObject, UIApplicationDelegate {
    private let notificationDelegate = NotificationDelegate()
    
    func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        debugPrint("Appdelegate didFinishLaunchingWithOptions")
        GULAppDelegateSwizzler.registerAppDelegateInterceptor(self)
        UNUserNotificationCenter.current().delegate = notificationDelegate
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        return true
    }
    
    func application(_ application: UIApplication,
                          didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint("Appdelegate didRegisterForRemoteNotificationsWithDeviceToken")
        Messaging.messaging().apnsToken = deviceToken
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs device token: \(token)")
        // TODO: Send this token to your server for push notifications
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        debugPrint("FCM token:", fcmToken ?? "")
    }
}

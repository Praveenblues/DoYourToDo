import SwiftUI
import GoogleUtilities_AppDelegateSwizzler
import UserNotifications
import UIKit
import Firebase

@main
struct DoYourToDoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let notificationDelegate = NotificationDelegate()

    init() {
        // Set UNUserNotificationCenter delegate early to handle foreground display and taps
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await NotificationManager.shared.requestAuthorizationAndRegister()
                }
        }
    }
}

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// Requests notification authorization and registers for remote notifications on success.
    func requestAuthorizationAndRegister() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission not granted")
            }
        } catch {
            print("Notification authorization error: \(error)")
        }
    }
}

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

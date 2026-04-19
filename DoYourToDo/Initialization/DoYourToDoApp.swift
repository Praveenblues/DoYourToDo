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

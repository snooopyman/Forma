import SwiftUI
import SwiftData
import UserNotifications
import os

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Private Properties
    
    private let notificationDelegate = AppNotificationDelegate()
    
    // MARK: - Functions
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        return true
    }
}

@main
struct FormaApp: App {
    
    // MARK: - Environment
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            if let modelContainer = FormaModelContainer.shared {
                AppRootView()
                    .modelContainer(modelContainer)
            } else {
                ContentUnavailableView(
                    "Unable to load Forma",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Restart the app. If the problem persists, reinstall Forma.")
                )
            }
        }
    }
}

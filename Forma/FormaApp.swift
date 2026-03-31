import SwiftUI
import SwiftData
import os

@main
struct FormaApp: App {

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

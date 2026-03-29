import SwiftUI
import SwiftData
import os

@main
struct FormaApp: App {

    // MARK: - States

    @State private var container: AppContainer?
    @State private var containerError: Error?

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            Group {
                if let container {
                    MainTabView()
                        .environment(container)
                } else if containerError != nil {
                    ContentUnavailableView(
                        "Unable to load Forma",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Restart the app. If the problem persists, reinstall Forma.")
                    )
                } else {
                    ProgressView()
                }
            }
            .task {
                guard container == nil, containerError == nil else { return }
                do {
                    let modelContainer = try FormaModelContainer.make()
                    container = AppContainer(modelContext: modelContainer.mainContext)
                } catch {
                    Logger.core.error("ModelContainer failed: \(error, privacy: .public)")
                    containerError = error
                }
            }
        }
    }
}

//
//  AppRootView.swift
//  Forma
//
//  Created by Armando Cáceres on 30/3/26.
//

import SwiftUI
import SwiftData

struct AppRootView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - States

    @AppStorage("tourCompleted") private var tourCompleted = false
    @Query private var profiles: [UserProfile]
    @State private var container: AppContainer?

    // MARK: - Computed Properties

    private var userProfile: UserProfile? { profiles.first }

    // MARK: - Body

    var body: some View {
        Group {
            if let container {
                if !tourCompleted {
                    OnboardingView()
                } else if userProfile == nil {
                    ProfileSetupView(
                        repository: container.userProfileRepository,
                        healthKitService: container.healthKitService,
                        notificationService: container.notificationService,
                        measurementReminderScheduler: container.measurementReminderScheduler
                    )
                } else {
                    MainTabView()
                        .environment(container)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            guard container == nil else { return }
            container = AppContainer(modelContext: modelContext)
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, let container else { return }
            Task { await container.measurementReminderScheduler.reschedule() }
        }
    }
}

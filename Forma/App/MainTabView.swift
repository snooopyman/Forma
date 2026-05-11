//
//  MainTabView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

enum AppTab: String {
    case today
    case training
    case nutrition
    case progress
}

struct MainTabView: View {

    // MARK: - States

    @AppStorage("postOnboardingAction") private var postOnboardingAction: AppTab = .today
    @AppStorage("selectedTab") private var selectedTab: AppTab = .today

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "house.fill", value: AppTab.today) {
                NavigationStack {
                    DashboardView()
                }
            }
            Tab("Training", systemImage: "figure.strengthtraining.traditional", value: AppTab.training) {
                NavigationStack {
                    MesocycleListView(mesocycleRepository: container.mesocycleRepository)
                }
            }
            Tab("Nutrition", systemImage: "fork.knife", value: AppTab.nutrition) {
                NavigationStack {
                    PlanOverviewView(nutritionRepository: container.nutritionRepository, macroService: container.macroTrackingService)
                }
            }
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis", value: AppTab.progress) {
                NavigationStack {
                    ProgressOverviewView(repository: container.bodyMeasurementRepository)
                }
            }
        }
        .onAppear {
            if postOnboardingAction != .today {
                selectedTab = postOnboardingAction
            }
        }
    }
}

#Preview {
    MainTabView()
}

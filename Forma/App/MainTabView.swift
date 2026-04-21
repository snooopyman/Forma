//
//  MainTabView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct MainTabView: View {

    // MARK: - States

    @State private var selectedTab: String = {
        switch UserDefaults.standard.string(forKey: "postOnboardingAction") ?? "" {
        case "training": return "training"
        case "nutrition": return "nutrition"
        default: return "today"
        }
    }()

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "house.fill", value: "today") {
                NavigationStack {
                    DashboardView()
                }
            }
            Tab("Training", systemImage: "figure.strengthtraining.traditional", value: "training") {
                NavigationStack {
                    MesocycleListView(mesocycleRepository: container.mesocycleRepository)
                }
            }
            Tab("Nutrition", systemImage: "fork.knife", value: "nutrition") {
                NavigationStack {
                    PlanOverviewView(nutritionRepository: container.nutritionRepository, macroService: container.macroTrackingService)
                }
            }
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis", value: "progress") {
                NavigationStack {
                    ProgressOverviewView(repository: container.bodyMeasurementRepository)
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}

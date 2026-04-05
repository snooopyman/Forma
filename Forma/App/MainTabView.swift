//
//  MainTabView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct MainTabView: View {

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - Body

    var body: some View {
        TabView {
            Tab("Today", systemImage: "house.fill") {
                NavigationStack {
                    DashboardView()
                }
            }
            Tab("Training", systemImage: "figure.strengthtraining.traditional") {
                NavigationStack {
                    MesocycleListView(mesocycleRepository: container.mesocycleRepository)
                }
            }
            Tab("Nutrition", systemImage: "fork.knife") {
                NavigationStack {
                    PlanOverviewView(nutritionRepository: container.nutritionRepository, macroService: container.macroTrackingService)
                }
            }
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis") {
                NavigationStack {
                    ProgressOverviewView()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}

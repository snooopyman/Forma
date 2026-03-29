//
//  MainTabView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct MainTabView: View {

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
                    MesocycleListView()
                }
            }
            Tab("Nutrition", systemImage: "fork.knife") {
                NavigationStack {
                    PlanOverviewView()
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

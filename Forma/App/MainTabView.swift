//
//  MainTabView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

enum AppTab: String, Hashable {
    case today
    case training
    case nutrition
    case progress
}

struct MainTabView: View {

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - States

    @AppStorage("postOnboardingAction") private var postOnboardingAction: AppTab = .today
    @AppStorage("selectedTab") private var selectedTab: AppTab = .today

    @State private var dashboardViewModel: DashboardViewModel?
    @State private var mesocycleListViewModel: MesocycleListViewModel?
    @State private var planOverviewViewModel: PlanOverviewViewModel?
    @State private var progressOverviewViewModel: ProgressOverviewViewModel?

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(String(localized: "Today"), systemImage: "house.fill", value: AppTab.today) {
                NavigationStack { DashboardView() }
            }
            Tab(String(localized: "Training"), systemImage: "figure.strengthtraining.traditional", value: AppTab.training) {
                NavigationStack { MesocycleListView() }
            }
            Tab(String(localized: "Nutrition"), systemImage: "fork.knife", value: AppTab.nutrition) {
                NavigationStack { PlanOverviewView() }
            }
            Tab(String(localized: "Progress"), systemImage: "chart.line.uptrend.xyaxis", value: AppTab.progress) {
                NavigationStack { ProgressOverviewView() }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
        .environment(\.dashboardViewModel, dashboardViewModel)
        .environment(\.mesocycleListViewModel, mesocycleListViewModel)
        .environment(\.planOverviewViewModel, planOverviewViewModel)
        .environment(\.progressOverviewViewModel, progressOverviewViewModel)
        .task {
            guard dashboardViewModel == nil else { return }

            let dashboardInteractor = DashboardInteractor(
                mesocycleRepo: container.mesocycleRepository,
                sessionRepo: container.workoutSessionRepository,
                nutritionRepo: container.nutritionRepository,
                measurementRepo: container.bodyMeasurementRepository,
                macroService: container.macroTrackingService,
                healthKitService: container.healthKitService
            )
            dashboardViewModel = DashboardViewModel(interactor: dashboardInteractor)

            mesocycleListViewModel = MesocycleListViewModel(
                interactor: MesocycleListInteractor(repository: container.mesocycleRepository)
            )

            planOverviewViewModel = PlanOverviewViewModel(
                interactor: PlanOverviewInteractor(
                    nutritionRepository: container.nutritionRepository,
                    macroService: container.macroTrackingService
                )
            )

            progressOverviewViewModel = ProgressOverviewViewModel(
                interactor: ProgressInteractor(repository: container.bodyMeasurementRepository)
            )
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

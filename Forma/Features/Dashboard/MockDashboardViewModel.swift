//
//  MockDashboardViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

@Observable
@MainActor
final class MockDashboardViewModel: DashboardViewModelProtocol {

    // MARK: - States

    var activeMesocycle: Mesocycle?
    var todayWorkoutDay: WorkoutDay?
    var inProgressSession: WorkoutSession?
    var isTodaySessionCompleted: Bool = false
    var macroSummary: DailyMacroSummary?
    var hasActivePlan: Bool = false
    var todaySteps: Int = 0
    var todayActiveCalories: Double = 0
    var todayExerciseMinutes: Double = 0
    var healthKitAuthorized: Bool = false
    var showMeasurementReminder: Bool = false
    var weeklyCompletedSessions: Int = 0
    var weeklyPlannedDays: Int = 0
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var isHealthKitAvailable: Bool { false }
    var greeting: String { L10n.Dashboard.goodMorning }
    var todayFormatted: String { Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)) }

    // MARK: - Functions

    func load() async { }
    func requestHealthKitAccess() async { }
}

// MARK: - Preview Factories

extension MockDashboardViewModel {
    static var empty: MockDashboardViewModel { MockDashboardViewModel() }

    static var loading: MockDashboardViewModel {
        let vm = MockDashboardViewModel()
        vm.isLoading = true
        return vm
    }

    static var withData: MockDashboardViewModel {
        let vm = MockDashboardViewModel()
        vm.weeklyCompletedSessions = 3
        vm.weeklyPlannedDays = 5
        return vm
    }

    static var withError: MockDashboardViewModel {
        let vm = MockDashboardViewModel()
        vm.errorMessage = L10n.Error.generic
        return vm
    }
}

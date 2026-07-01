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
    var isHealthKitAvailable: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Computed Properties

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

        let mesocycle = Mesocycle(
            name: "Hipertrofia Bloque 1",
            startDate: Calendar.current.date(byAdding: .day, value: -14, to: .now)!,
            durationWeeks: 6,
            useFixedDays: false,
            isActive: true
        )
        let workoutDay = WorkoutDay(name: "Push", order: 0, weekday: .monday)
        workoutDay.mesocycle = mesocycle
        workoutDay.plannedExercises = (0..<5).map { PlannedExercise(order: $0) }
        mesocycle.workoutDays = [workoutDay]

        vm.activeMesocycle = mesocycle
        vm.todayWorkoutDay = workoutDay
        vm.isTodaySessionCompleted = false

        vm.macroSummary = DailyMacroSummary(
            consumedCalories: 1450,
            consumedProteinG: 110,
            consumedCarbsG: 140,
            consumedFatG: 40,
            targetCalories: 2800,
            targetProteinG: 180,
            targetCarbsG: 320,
            targetFatG: 75
        )
        vm.hasActivePlan = true

        vm.isHealthKitAvailable = true
        vm.healthKitAuthorized = true
        vm.todaySteps = 6_240
        vm.todayActiveCalories = 380
        vm.todayExerciseMinutes = 22

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

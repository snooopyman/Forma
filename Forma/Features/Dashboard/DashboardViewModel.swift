//
//  DashboardViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 19/4/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class DashboardViewModel: DashboardViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored private let healthKitAuthorizedKey = "com.armando.forma.healthKitAuthorized"
    @ObservationIgnored private let interactor: DashboardInteractorProtocol

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

    var isHealthKitAvailable: Bool { interactor.isHealthKitAvailable }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 12 { return String(localized: "Good morning") }
        if hour < 18 { return String(localized: "Good afternoon") }
        return String(localized: "Good evening")
    }

    var todayFormatted: String {
        Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    // MARK: - Initializers

    init(interactor: DashboardInteractorProtocol) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let snapshot = try await interactor.loadDashboardData()
            activeMesocycle         = snapshot.activeMesocycle
            todayWorkoutDay         = snapshot.todayWorkoutDay
            inProgressSession       = snapshot.inProgressSession
            isTodaySessionCompleted = snapshot.isTodaySessionCompleted
            weeklyCompletedSessions = snapshot.weeklyCompletedSessions
            weeklyPlannedDays       = snapshot.weeklyPlannedDays
            macroSummary            = snapshot.macroSummary
            hasActivePlan           = snapshot.hasActivePlan
            showMeasurementReminder = snapshot.showMeasurementReminder
            if UserDefaults.standard.bool(forKey: healthKitAuthorizedKey) {
                healthKitAuthorized = true
                await loadHealthKitData()
            }
        } catch {
            handleError(error)
        }
    }

    func requestHealthKitAccess() async {
        guard interactor.isHealthKitAvailable else { return }
        do {
            try await interactor.requestHealthKitAccess()
            healthKitAuthorized = true
            UserDefaults.standard.set(true, forKey: healthKitAuthorizedKey)
            await loadHealthKitData()
        } catch {
            Logger.healthKit.error("Error: \(error, privacy: .private)")
        }
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        Logger.core.error("Error: \(error, privacy: .private)")
        if let trainingError = error as? TrainingError {
            errorMessage = trainingError.errorDescription
        } else if let nutritionError = error as? NutritionError {
            errorMessage = nutritionError.errorDescription
        } else if let progressError = error as? ProgressError {
            errorMessage = progressError.errorDescription
        } else {
            errorMessage = String(localized: "Something went wrong")
        }
    }

    private func loadHealthKitData() async {
        let health = await interactor.refreshHealthData()
        todaySteps = health.steps
        todayActiveCalories = health.activeCalories
        todayExerciseMinutes = health.exerciseMinutes
    }
}

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
final class DashboardViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored private let healthKitAuthorizedKey = "com.armando.forma.healthKitAuthorized"
    @ObservationIgnored private let mesocycleRepo: MesocycleRepositoryProtocol
    @ObservationIgnored private let workoutSessionRepo: WorkoutSessionRepositoryProtocol
    @ObservationIgnored private let nutritionRepo: NutritionRepositoryProtocol
    @ObservationIgnored private let bodyMeasurementRepo: BodyMeasurementRepositoryProtocol
    @ObservationIgnored private let macroTrackingService: MacroTrackingServiceProtocol
    @ObservationIgnored private let healthKitService: HealthKitServiceProtocol
    
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
    
    var isHealthKitAvailable: Bool { healthKitService.isAvailable }
    
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
    
    init(
        mesocycleRepo: MesocycleRepositoryProtocol,
        workoutSessionRepo: WorkoutSessionRepositoryProtocol,
        nutritionRepo: NutritionRepositoryProtocol,
        bodyMeasurementRepo: BodyMeasurementRepositoryProtocol,
        macroTrackingService: MacroTrackingServiceProtocol,
        healthKitService: HealthKitServiceProtocol
    ) {
        self.mesocycleRepo = mesocycleRepo
        self.workoutSessionRepo = workoutSessionRepo
        self.nutritionRepo = nutritionRepo
        self.bodyMeasurementRepo = bodyMeasurementRepo
        self.macroTrackingService = macroTrackingService
        self.healthKitService = healthKitService
    }
    
    // MARK: - Functions
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            activeMesocycle = try await mesocycleRepo.fetchActive()
            inProgressSession = try await workoutSessionRepo.fetchInProgress()
            try await loadNutrition()
            let latestMeasurement = try await bodyMeasurementRepo.fetchLatest()
            
            if let mesocycle = activeMesocycle {
                await loadWorkoutData(for: mesocycle)
            }
            
            showMeasurementReminder = shouldShowMeasurementReminder(latestMeasurement)
            
            if UserDefaults.standard.bool(forKey: healthKitAuthorizedKey) {
                healthKitAuthorized = true
                await loadHealthKitData()
            }
        } catch {
            handleError(error)
        }
    }
    
    func requestHealthKitAccess() async {
        guard healthKitService.isAvailable else { return }
        do {
            try await healthKitService.requestAuthorization()
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
    
    private func loadNutrition() async throws {
        guard let plan = try await nutritionRepo.fetchActivePlan() else {
            hasActivePlan = false
            return
        }
        hasActivePlan = true
        let log = try await nutritionRepo.fetchLog(for: .now)
        macroSummary = macroTrackingService.computeDailySummary(plan: plan, log: log)
    }
    
    private func loadWorkoutData(for mesocycle: Mesocycle) async {
        weeklyPlannedDays = mesocycle.workoutDays.filter { !$0.isRestDay }.count
        let allSessions = (try? await workoutSessionRepo.fetchAll(for: mesocycle)) ?? []
        
        if mesocycle.useFixedDays {
            todayWorkoutDay = resolveTodayWorkoutDay(from: mesocycle)
            if let day = todayWorkoutDay, !day.isRestDay {
                let completed = (try? await workoutSessionRepo.fetchCompleted(for: day)) ?? []
                isTodaySessionCompleted = completed.contains { Calendar.current.isDateInToday($0.date) }
            }
        } else {
            resolveNonFixedWorkoutDay(for: mesocycle, allSessions: allSessions)
        }
        
        loadWeeklySummary(allSessions: allSessions)
    }
    
    private func resolveNonFixedWorkoutDay(for mesocycle: Mesocycle, allSessions: [WorkoutSession]) {
        let range = currentWeekDateRange()
        let completedThisWeek = allSessions.filter { $0.isCompleted && range.contains($0.date) }
        let completedDayIDs = Set(completedThisWeek.compactMap { $0.workoutDay?.id })
        
        todayWorkoutDay = mesocycle.workoutDays
            .sorted { $0.order < $1.order }
            .first { !completedDayIDs.contains($0.id) }
        
        isTodaySessionCompleted = false
    }
    
    private func loadWeeklySummary(allSessions: [WorkoutSession]) {
        let range = currentWeekDateRange()
        weeklyCompletedSessions = allSessions.filter { $0.isCompleted && range.contains($0.date) }.count
    }
    
    private func loadHealthKitData() async {
        async let steps = healthKitService.fetchTodaySteps()
        async let calories = healthKitService.fetchTodayActiveCalories()
        async let minutes = healthKitService.fetchTodayExerciseMinutes()
        (todaySteps, todayActiveCalories, todayExerciseMinutes) = await (steps, calories, minutes)
    }
    
    private func resolveTodayWorkoutDay(from mesocycle: Mesocycle) -> WorkoutDay? {
        let today = currentWeekdayEnum()
        return mesocycle.workoutDays.first { $0.weekday == today }
    }
    
    private func currentWeekdayEnum() -> Weekday {
        switch Calendar.current.component(.weekday, from: .now) {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .saturday
        }
    }
    
    private func currentWeekDateRange() -> ClosedRange<Date> {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        let end = cal.date(byAdding: .day, value: 7, to: start) ?? .now
        return start...end
    }
    
    private func shouldShowMeasurementReminder(_ latest: BodyMeasurement?) -> Bool {
        guard let latest else { return true }
        let daysSince = Calendar.current.dateComponents([.day], from: latest.date, to: .now).day ?? 0
        let isMonday = Calendar.current.component(.weekday, from: .now) == 2
        return isMonday || daysSince > 6
    }
}

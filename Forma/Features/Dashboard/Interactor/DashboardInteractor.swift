//
//  DashboardInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class DashboardInteractor: DashboardInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let mesocycleRepo: MesocycleRepositoryProtocol
    private let sessionRepo: WorkoutSessionRepositoryProtocol
    private let nutritionRepo: NutritionRepositoryProtocol
    private let measurementRepo: BodyMeasurementRepositoryProtocol
    private let macroService: MacroTrackingServiceProtocol
    private let healthKitService: HealthKitServiceProtocol
    
    // MARK: - Initializers
    
    init(
        mesocycleRepo: MesocycleRepositoryProtocol,
        sessionRepo: WorkoutSessionRepositoryProtocol,
        nutritionRepo: NutritionRepositoryProtocol,
        measurementRepo: BodyMeasurementRepositoryProtocol,
        macroService: MacroTrackingServiceProtocol,
        healthKitService: HealthKitServiceProtocol
    ) {
        self.mesocycleRepo = mesocycleRepo
        self.sessionRepo = sessionRepo
        self.nutritionRepo = nutritionRepo
        self.measurementRepo = measurementRepo
        self.macroService = macroService
        self.healthKitService = healthKitService
    }
    
    // MARK: - Computed Properties

    var isHealthKitAvailable: Bool { healthKitService.isAvailable }

    // MARK: - Functions

    func loadDashboardData() async throws -> DashboardSnapshot {
        let mesocycle = try await mesocycleRepo.fetchActive()
        let inProgress = try await sessionRepo.fetchInProgress()
        let measurement = try await measurementRepo.fetchLatest()
        let plan = try await nutritionRepo.fetchActivePlan()
        
        var macroSummary: DailyMacroSummary?
        let hasActivePlan = plan != nil
        
        if let plan {
            let todayLog = try await nutritionRepo.fetchLog(for: .now)
            macroSummary = macroService.computeDailySummary(plan: plan, log: todayLog)
        }
        
        var todayWorkoutDay: WorkoutDay?
        var isTodaySessionCompleted = false
        var weeklyCompletedSessions = 0
        var weeklyPlannedDays = 0
        
        if let mesocycle {
            let weekRange = currentWeekDateRange()
            weeklyPlannedDays = mesocycle.workoutDays.filter { !$0.isRestDay }.count
            let allSessions = (try? await sessionRepo.fetchAll(for: mesocycle)) ?? []
            weeklyCompletedSessions = allSessions.filter { $0.isCompleted && weekRange.contains($0.date) }.count
            
            if mesocycle.useFixedDays {
                todayWorkoutDay = resolveTodayWorkoutDay(from: mesocycle)
                if let day = todayWorkoutDay, !day.isRestDay {
                    let completed = (try? await sessionRepo.fetchCompleted(for: day)) ?? []
                    isTodaySessionCompleted = completed.contains { Calendar.current.isDateInToday($0.date) }
                }
            } else {
                let completedThisWeek = allSessions.filter { $0.isCompleted && weekRange.contains($0.date) }
                let completedDayIDs = Set(completedThisWeek.compactMap { $0.workoutDay?.id })
                todayWorkoutDay = mesocycle.workoutDays
                    .sorted { $0.order < $1.order }
                    .first { !completedDayIDs.contains($0.id) }
            }
        }
        
        return DashboardSnapshot(
            activeMesocycle: mesocycle,
            todayWorkoutDay: todayWorkoutDay,
            inProgressSession: inProgress,
            isTodaySessionCompleted: isTodaySessionCompleted,
            weeklyCompletedSessions: weeklyCompletedSessions,
            weeklyPlannedDays: weeklyPlannedDays,
            macroSummary: macroSummary,
            hasActivePlan: hasActivePlan,
            showMeasurementReminder: shouldShowMeasurementReminder(measurement)
        )
    }
    
    func requestHealthKitAccess() async throws {
        try await healthKitService.requestAuthorization()
    }
    
    func refreshHealthData() async -> HealthSnapshot {
        async let steps = healthKitService.fetchTodaySteps()
        async let calories = healthKitService.fetchTodayActiveCalories()
        async let minutes = healthKitService.fetchTodayExerciseMinutes()
        let (s, c, m) = await (steps, calories, minutes)
        return HealthSnapshot(steps: s, activeCalories: c, exerciseMinutes: m)
    }
    
    // MARK: - Private Functions
    
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

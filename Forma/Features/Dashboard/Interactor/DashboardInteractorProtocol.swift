//
//  DashboardInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

struct DashboardSnapshot {
    let activeMesocycle: Mesocycle?
    let todayWorkoutDay: WorkoutDay?
    let inProgressSession: WorkoutSession?
    let isTodaySessionCompleted: Bool
    let weeklyCompletedSessions: Int
    let weeklyPlannedDays: Int
    let macroSummary: DailyMacroSummary?
    let hasActivePlan: Bool
    let showMeasurementReminder: Bool
}

struct HealthSnapshot: Sendable {
    let steps: Int
    let activeCalories: Double
    let exerciseMinutes: Double
}


protocol DashboardInteractorProtocol: Sendable {
    var isHealthKitAvailable: Bool { get }
    func loadDashboardData() async throws -> DashboardSnapshot
    func requestHealthKitAccess() async throws
    func refreshHealthData() async -> HealthSnapshot
}

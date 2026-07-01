//
//  MockDashboardInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockDashboardInteractor: DashboardInteractorProtocol {

    // MARK: - Computed Properties

    var isHealthKitAvailable: Bool { false }

    // MARK: - Stub Data

    nonisolated(unsafe) var stubbedSnapshot = DashboardSnapshot(
        activeMesocycle: nil,
        todayWorkoutDay: nil,
        inProgressSession: nil,
        isTodaySessionCompleted: false,
        weeklyCompletedSessions: 0,
        weeklyPlannedDays: 0,
        macroSummary: nil,
        hasActivePlan: false,
        showMeasurementReminder: false
    )
    nonisolated(unsafe) var stubbedHealthSnapshot = HealthSnapshot(steps: 0, activeCalories: 0, exerciseMinutes: 0)
    nonisolated(unsafe) var shouldThrowOnLoad = false

    // MARK: - Functions

    func loadDashboardData() async throws -> DashboardSnapshot {
        if shouldThrowOnLoad { throw TrainingError.loadFailed }
        return stubbedSnapshot
    }

    func requestHealthKitAccess() async throws { }

    func refreshHealthData() async -> HealthSnapshot {
        stubbedHealthSnapshot
    }
}

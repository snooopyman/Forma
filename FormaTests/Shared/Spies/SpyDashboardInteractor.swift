//
//  SpyDashboardInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation
@testable import Forma

final class SpyDashboardInteractor: DashboardInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var loadDashboardDataWasCalled = false
    private(set) var requestHealthKitAccessWasCalled = false
    private(set) var refreshHealthDataWasCalled = false
    
    // MARK: - Stub Data
    
    var isHealthKitAvailable: Bool = false
    var stubbedSnapshot: DashboardSnapshot? = nil
    var stubbedHealthSnapshot = HealthSnapshot(steps: 0, activeCalories: 0, exerciseMinutes: 0)
    var shouldThrowError = false
    var errorToThrow: Error = TrainingError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        loadDashboardDataWasCalled = false
        requestHealthKitAccessWasCalled = false
        refreshHealthDataWasCalled = false
    }
    
    func loadDashboardData() async throws -> DashboardSnapshot {
        loadDashboardDataWasCalled = true
        if shouldThrowError { throw errorToThrow }
        guard let snapshot = stubbedSnapshot else {
            throw TrainingError.loadFailed
        }
        return snapshot
    }
    
    func requestHealthKitAccess() async throws {
        requestHealthKitAccessWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
    
    func refreshHealthData() async -> HealthSnapshot {
        refreshHealthDataWasCalled = true
        return stubbedHealthSnapshot
    }
}

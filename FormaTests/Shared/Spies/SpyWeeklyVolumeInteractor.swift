//
//  SpyWeeklyVolumeInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 25/7/26.
//

import Foundation
@testable import Forma

final class SpyWeeklyVolumeInteractor: WeeklyVolumeInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var loadSnapshotWasCalled = false
    private(set) var fetchTargetsWasCalled = false
    private(set) var seedDefaultTargetsWasCalled = false
    private(set) var restoreDefaultTargetsWasCalled = false
    private(set) var saveTargetWasCalled = false
    private(set) var lastSavedTarget: MuscleVolumeTarget?
    
    // MARK: - Stub Data
    
    var stubbedSnapshot = WeeklyVolumeSnapshot(
        weekRange: Date.now..<Date.now.addingTimeInterval(1),
        coachings: [],
        hasCompletedSessionsThisWeek: false,
        hasTargetsConfigured: false
    )
    var stubbedTargets: [MuscleVolumeTarget] = []
    var shouldThrowError = false
    var errorToThrow: Error = ProgressError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        loadSnapshotWasCalled = false
        fetchTargetsWasCalled = false
        seedDefaultTargetsWasCalled = false
        restoreDefaultTargetsWasCalled = false
        saveTargetWasCalled = false
        lastSavedTarget = nil
    }
    
    func loadSnapshot() async throws -> WeeklyVolumeSnapshot {
        loadSnapshotWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedSnapshot
    }
    
    func fetchTargets() async throws -> [MuscleVolumeTarget] {
        fetchTargetsWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedTargets
    }
    
    func seedDefaultTargets() async throws {
        seedDefaultTargetsWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
    
    func restoreDefaultTargets() async throws {
        restoreDefaultTargetsWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
    
    func saveTarget(_ target: MuscleVolumeTarget) async throws {
        saveTargetWasCalled = true
        lastSavedTarget = target
        if shouldThrowError { throw errorToThrow }
    }
}

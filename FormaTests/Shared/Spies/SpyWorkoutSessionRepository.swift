//
//  SpyWorkoutSessionRepository.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation
@testable import Forma

final class SpyWorkoutSessionRepository: WorkoutSessionRepositoryProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var fetchAllWasCalled = false
    private(set) var fetchInProgressWasCalled = false
    private(set) var saveWasCalled = false
    private(set) var deleteWasCalled = false
    private(set) var addSetWasCalled = false
    private(set) var deleteSetWasCalled = false
    private(set) var fetchCompletedWasCalled = false
    private(set) var lastSavedSession: WorkoutSession?
    private(set) var lastDeletedSession: WorkoutSession?
    
    // MARK: - Stub Data
    
    var stubbedSessions: [WorkoutSession] = []
    var stubbedInProgress: WorkoutSession?
    var stubbedCompleted: [WorkoutSession] = []
    var shouldThrowError = false
    var errorToThrow: Error = TrainingError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchAllWasCalled = false
        fetchInProgressWasCalled = false
        saveWasCalled = false
        deleteWasCalled = false
        addSetWasCalled = false
        deleteSetWasCalled = false
        fetchCompletedWasCalled = false
        lastSavedSession = nil
        lastDeletedSession = nil
    }
    
    func fetchAll(for mesocycle: Mesocycle) async throws -> [WorkoutSession] {
        fetchAllWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedSessions
    }
    
    func fetchInProgress() async throws -> WorkoutSession? {
        fetchInProgressWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedInProgress
    }
    
    func save(_ session: WorkoutSession) async throws {
        saveWasCalled = true
        lastSavedSession = session
        if shouldThrowError { throw errorToThrow }
    }
    
    func delete(_ session: WorkoutSession) async throws {
        deleteWasCalled = true
        lastDeletedSession = session
        if shouldThrowError { throw errorToThrow }
    }
    
    func addSet(_ set: LoggedSet, to session: WorkoutSession) async throws {
        addSetWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
    
    func deleteSet(_ set: LoggedSet) async throws {
        deleteSetWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
    
    func fetchCompleted(for workoutDay: WorkoutDay) async throws -> [WorkoutSession] {
        fetchCompletedWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedCompleted
    }
}

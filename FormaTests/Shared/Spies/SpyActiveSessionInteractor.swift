//
//  SpyActiveSessionInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation
import HealthKit
@testable import Forma

final class SpyActiveSessionInteractor: ActiveSessionInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var logSetWasCalled = false
    private(set) var deleteSetWasCalled = false
    private(set) var completeSessionWasCalled = false
    private(set) var discardSessionWasCalled = false
    private(set) var fetchLastSetsWasCalled = false
    private(set) var startRestActivityWasCalled = false
    private(set) var endRestActivityWasCalled = false
    private(set) var writeWorkoutWasCalled = false
    private(set) var lastLoggedInput: SetInput?
    private(set) var lastDeletedSet: LoggedSet?
    private(set) var lastCompletedSession: WorkoutSession?
    private(set) var lastDiscardedSession: WorkoutSession?
    
    // MARK: - Stub Data
    
    var stubbedLoggedSet: LoggedSet?
    var stubbedLastSets: [LoggedSet] = []
    var shouldThrowError = false
    var errorToThrow: Error = TrainingError.logSetFailed
    
    // MARK: - Functions
    
    func reset() {
        logSetWasCalled = false
        deleteSetWasCalled = false
        completeSessionWasCalled = false
        discardSessionWasCalled = false
        fetchLastSetsWasCalled = false
        startRestActivityWasCalled = false
        endRestActivityWasCalled = false
        writeWorkoutWasCalled = false
        lastLoggedInput = nil
        lastDeletedSet = nil
        lastCompletedSession = nil
        lastDiscardedSession = nil
    }
    
    func logSet(_ input: SetInput, order: Int, to session: WorkoutSession, plannedExercise: PlannedExercise?) async throws -> LoggedSet {
        logSetWasCalled = true
        lastLoggedInput = input
        if shouldThrowError { throw errorToThrow }
        return stubbedLoggedSet ?? LoggedSet(order: order, exerciseName: input.exerciseName, weightKg: input.weightKg, reps: input.reps, rirActual: input.rirActual)
    }
    
    func deleteSet(_ set: LoggedSet, from session: WorkoutSession) async throws {
        deleteSetWasCalled = true
        lastDeletedSet = set
        if shouldThrowError { throw errorToThrow }
    }
    
    func completeSession(_ session: WorkoutSession) async throws {
        completeSessionWasCalled = true
        lastCompletedSession = session
        if shouldThrowError { throw errorToThrow }
    }
    
    func discardSession(_ session: WorkoutSession) async throws {
        discardSessionWasCalled = true
        lastDiscardedSession = session
        if shouldThrowError { throw errorToThrow }
    }
    
    func fetchLastSets(for workoutDay: WorkoutDay, exerciseName: String) async throws -> [LoggedSet] {
        fetchLastSetsWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedLastSets
    }
    
    func startRestActivity(exerciseName: String, seconds: Int) async {
        startRestActivityWasCalled = true
    }
    
    func endRestActivity() async {
        endRestActivityWasCalled = true
    }
    
    func writeWorkout(activityType: HKWorkoutActivityType, start: Date, end: Date) async {
        writeWorkoutWasCalled = true
    }
}

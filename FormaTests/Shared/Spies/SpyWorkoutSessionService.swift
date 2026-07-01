//
//  SpyWorkoutSessionService.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyWorkoutSessionService: WorkoutSessionServiceProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var startSessionWasCalled = false
    private(set) var logSetWasCalled = false
    private(set) var deleteSetWasCalled = false
    private(set) var completeSessionWasCalled = false
    private(set) var discardSessionWasCalled = false
    private(set) var fetchLastSetsWasCalled = false
    private(set) var lastCompletedSession: WorkoutSession?
    private(set) var lastDiscardedSession: WorkoutSession?

    // MARK: - Stub Data

    var stubbedStartedSession: WorkoutSession?
    var stubbedLoggedSet: LoggedSet?
    var stubbedLastSets: [LoggedSet] = []
    var shouldThrowError = false
    var errorToThrow: Error = TrainingError.loadFailed

    // MARK: - Functions

    func reset() {
        startSessionWasCalled = false
        logSetWasCalled = false
        deleteSetWasCalled = false
        completeSessionWasCalled = false
        discardSessionWasCalled = false
        fetchLastSetsWasCalled = false
        lastCompletedSession = nil
        lastDiscardedSession = nil
    }

    func startSession(for workoutDay: WorkoutDay, in mesocycle: Mesocycle) async throws -> WorkoutSession {
        startSessionWasCalled = true
        if shouldThrowError { throw errorToThrow }
        guard let session = stubbedStartedSession else { throw TrainingError.sessionNotFound }
        return session
    }

    func logSet(_ input: SetInput, order: Int, to session: WorkoutSession, plannedExercise: PlannedExercise?) async throws -> LoggedSet {
        logSetWasCalled = true
        if shouldThrowError { throw errorToThrow }
        guard let set = stubbedLoggedSet else { throw TrainingError.logSetFailed }
        return set
    }

    func deleteSet(_ set: LoggedSet, from session: WorkoutSession) async throws {
        deleteSetWasCalled = true
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
}

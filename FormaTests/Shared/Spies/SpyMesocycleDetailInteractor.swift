//
//  SpyMesocycleDetailInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyMesocycleDetailInteractor: MesocycleDetailInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var fetchSessionsWasCalled = false
    private(set) var fetchInProgressSessionWasCalled = false
    private(set) var activateWasCalled = false
    private(set) var pauseWasCalled = false
    private(set) var resumeWasCalled = false
    private(set) var addWorkoutDayWasCalled = false
    private(set) var lastAddedDay: WorkoutDay?

    // MARK: - Stub Data

    var stubbedSessions: [WorkoutSession] = []
    var stubbedInProgressSession: WorkoutSession?
    var shouldThrowError = false
    var errorToThrow: Error = TrainingError.loadFailed

    // MARK: - Functions

    func reset() {
        fetchSessionsWasCalled = false
        fetchInProgressSessionWasCalled = false
        activateWasCalled = false
        pauseWasCalled = false
        resumeWasCalled = false
        addWorkoutDayWasCalled = false
        lastAddedDay = nil
    }

    func fetchSessions(for mesocycle: Mesocycle) async throws -> [WorkoutSession] {
        fetchSessionsWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedSessions
    }

    func fetchInProgressSession() async throws -> WorkoutSession? {
        fetchInProgressSessionWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedInProgressSession
    }

    func activate(_ mesocycle: Mesocycle) async throws {
        activateWasCalled = true
        if shouldThrowError { throw errorToThrow }
        mesocycle.isActive = true
    }

    func pause(_ mesocycle: Mesocycle) async throws {
        pauseWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }

    func resume(_ mesocycle: Mesocycle) async throws {
        resumeWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }

    func addWorkoutDay(_ day: WorkoutDay, to mesocycle: Mesocycle) async throws {
        addWorkoutDayWasCalled = true
        lastAddedDay = day
        if shouldThrowError { throw errorToThrow }
        mesocycle.workoutDays.append(day)
    }
}

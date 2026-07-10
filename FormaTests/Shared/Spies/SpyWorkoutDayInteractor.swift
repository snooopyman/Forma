//
//  SpyWorkoutDayInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyWorkoutDayInteractor: WorkoutDayInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var fetchInProgressSessionWasCalled = false
    private(set) var deletePlannedExerciseWasCalled = false
    private(set) var startSessionWasCalled = false
    private(set) var addPlannedExerciseWasCalled = false
    private(set) var updatePlannedExerciseWasCalled = false
    private(set) var lastDeletedExercise: PlannedExercise?
    private(set) var lastAddedExercise: PlannedExercise?
    private(set) var lastUpdatedExercise: PlannedExercise?

    // MARK: - Stub Data

    var stubbedInProgressSession: WorkoutSession?
    var stubbedStartedSession: WorkoutSession?
    var shouldThrowError = false
    var errorToThrow: Error = TrainingError.loadFailed

    // MARK: - Functions

    func reset() {
        fetchInProgressSessionWasCalled = false
        deletePlannedExerciseWasCalled = false
        startSessionWasCalled = false
        addPlannedExerciseWasCalled = false
        updatePlannedExerciseWasCalled = false
        lastDeletedExercise = nil
        lastAddedExercise = nil
        lastUpdatedExercise = nil
    }

    func fetchInProgressSession() async throws -> WorkoutSession? {
        fetchInProgressSessionWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedInProgressSession
    }

    func deletePlannedExercise(_ planned: PlannedExercise) async throws {
        deletePlannedExerciseWasCalled = true
        lastDeletedExercise = planned
        if shouldThrowError { throw errorToThrow }
    }

    func startSession(for workoutDay: WorkoutDay, in mesocycle: Mesocycle) async throws -> WorkoutSession {
        startSessionWasCalled = true
        if shouldThrowError { throw errorToThrow }
        guard let session = stubbedStartedSession else { throw TrainingError.sessionNotFound }
        return session
    }

    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws {
        addPlannedExerciseWasCalled = true
        lastAddedExercise = planned
        if shouldThrowError { throw errorToThrow }
        day.plannedExercises.append(planned)
    }

    func updatePlannedExercise(
        _ planned: PlannedExercise,
        name: String,
        muscle: MuscleGroup,
        equipment: EquipmentType?,
        sets: Int,
        repsMin: Int,
        repsMax: Int,
        rir: Int,
        restSeconds: Int
    ) async throws {
        updatePlannedExerciseWasCalled = true
        lastUpdatedExercise = planned
        if shouldThrowError { throw errorToThrow }
    }
}

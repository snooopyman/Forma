//
//  MockWorkoutDayInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockWorkoutDayInteractor: WorkoutDayInteractorProtocol {
    
    // MARK: - Stub Data
    
    nonisolated(unsafe) var stubbedInProgressSession: WorkoutSession?
    nonisolated(unsafe) var stubbedStartedSession: WorkoutSession?
    nonisolated(unsafe) var shouldThrowOnLoad = false
    nonisolated(unsafe) var shouldThrowOnDelete = false
    nonisolated(unsafe) var shouldThrowOnStart = false
    nonisolated(unsafe) var shouldThrowOnMutate = false

    // MARK: - Functions
    
    func fetchInProgressSession() async throws -> WorkoutSession? {
        if shouldThrowOnLoad { throw TrainingError.loadFailed }
        return stubbedInProgressSession
    }
    
    func deletePlannedExercise(_ planned: PlannedExercise) async throws {
        if shouldThrowOnDelete { throw TrainingError.deleteFailed }
    }
    
    func startSession(for workoutDay: WorkoutDay, in mesocycle: Mesocycle) async throws -> WorkoutSession {
        if shouldThrowOnStart { throw TrainingError.saveFailed }
        guard let session = stubbedStartedSession else { throw TrainingError.sessionNotFound }
        return session
    }

    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws {
        if shouldThrowOnMutate { throw TrainingError.saveFailed }
        day.plannedExercises.append(planned)
    }

    func updatePlannedExercise(
        _ planned: PlannedExercise,
        name: String,
        muscle: MuscleGroup,
        sets: Int,
        repsMin: Int,
        repsMax: Int,
        rir: Int,
        restSeconds: Int
    ) async throws {
        if shouldThrowOnMutate { throw TrainingError.saveFailed }
    }
}

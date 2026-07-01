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
}

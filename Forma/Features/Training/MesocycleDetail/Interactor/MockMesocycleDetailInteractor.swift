//
//  MockMesocycleDetailInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockMesocycleDetailInteractor: MesocycleDetailInteractorProtocol {
    
    // MARK: - Stub Data
    
    nonisolated(unsafe) var stubbedSessions: [WorkoutSession] = []
    nonisolated(unsafe) var stubbedInProgressSession: WorkoutSession?
    nonisolated(unsafe) var shouldThrowOnLoad = false
    nonisolated(unsafe) var shouldThrowOnMutate = false
    
    // MARK: - Functions
    
    func fetchSessions(for mesocycle: Mesocycle) async throws -> [WorkoutSession] {
        if shouldThrowOnLoad { throw TrainingError.loadFailed }
        return stubbedSessions
    }
    
    func fetchInProgressSession() async throws -> WorkoutSession? {
        if shouldThrowOnLoad { throw TrainingError.loadFailed }
        return stubbedInProgressSession
    }
    
    func activate(_ mesocycle: Mesocycle) async throws {
        if shouldThrowOnMutate { throw TrainingError.setActiveFailed }
        mesocycle.isActive = true
    }
    
    func pause(_ mesocycle: Mesocycle) async throws {
        if shouldThrowOnMutate { throw TrainingError.saveFailed }
    }
    
    func resume(_ mesocycle: Mesocycle) async throws {
        if shouldThrowOnMutate { throw TrainingError.saveFailed }
    }
    
    func addWorkoutDay(_ day: WorkoutDay, to mesocycle: Mesocycle) async throws {
        if shouldThrowOnMutate { throw TrainingError.saveFailed }
        mesocycle.workoutDays.append(day)
    }
}

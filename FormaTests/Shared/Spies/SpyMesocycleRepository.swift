//
//  SpyMesocycleRepository.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation
@testable import Forma

final class SpyMesocycleRepository: MesocycleRepositoryProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var fetchAllWasCalled = false
    private(set) var fetchActiveWasCalled = false
    private(set) var saveWasCalled = false
    private(set) var deleteWasCalled = false
    private(set) var setActiveWasCalled = false
    private(set) var lastDeletedMesocycle: Mesocycle?
    private(set) var lastActivatedMesocycle: Mesocycle?
    
    // MARK: - Stub Data
    
    var stubbedMesocycles: [Mesocycle] = []
    var stubbedActiveMesocycle: Mesocycle?
    var shouldThrowError = false
    var errorToThrow: Error = TrainingError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchAllWasCalled = false
        fetchActiveWasCalled = false
        saveWasCalled = false
        deleteWasCalled = false
        setActiveWasCalled = false
        lastDeletedMesocycle = nil
        lastActivatedMesocycle = nil
    }
    
    func fetchAll() async throws -> [Mesocycle] {
        fetchAllWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedMesocycles
    }
    
    func fetchActive() async throws -> Mesocycle? {
        fetchActiveWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedActiveMesocycle
    }
    
    func save(_ mesocycle: Mesocycle) async throws {
        saveWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
    
    func delete(_ mesocycle: Mesocycle) async throws {
        deleteWasCalled = true
        lastDeletedMesocycle = mesocycle
        if shouldThrowError { throw errorToThrow }
    }
    
    func setActive(_ mesocycle: Mesocycle) async throws {
        setActiveWasCalled = true
        lastActivatedMesocycle = mesocycle
        if shouldThrowError { throw errorToThrow }
    }
    
    func pause(_ mesocycle: Mesocycle) async throws { }
    func resume(_ mesocycle: Mesocycle) async throws { }
    func addWorkoutDay(_ day: WorkoutDay, to mesocycle: Mesocycle) async throws { }
    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws { }
    func updatePlannedExercise(_ planned: PlannedExercise, name: String, muscle: MuscleGroup, sets: Int, repsMin: Int, repsMax: Int, rir: Int, restSeconds: Int) async throws { }
    func deletePlannedExercise(_ planned: PlannedExercise) async throws { }
}

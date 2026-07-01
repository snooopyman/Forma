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
    private(set) var pauseWasCalled = false
    private(set) var resumeWasCalled = false
    private(set) var addWorkoutDayWasCalled = false
    private(set) var addPlannedExerciseWasCalled = false
    private(set) var updatePlannedExerciseWasCalled = false
    private(set) var deletePlannedExerciseWasCalled = false
    private(set) var lastDeletedMesocycle: Mesocycle?
    private(set) var lastActivatedMesocycle: Mesocycle?
    private(set) var lastAddedWorkoutDay: WorkoutDay?
    private(set) var lastAddedPlannedExercise: PlannedExercise?
    private(set) var lastUpdatedPlannedExercise: PlannedExercise?
    private(set) var lastDeletedPlannedExercise: PlannedExercise?
    
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
        pauseWasCalled = false
        resumeWasCalled = false
        addWorkoutDayWasCalled = false
        addPlannedExerciseWasCalled = false
        updatePlannedExerciseWasCalled = false
        deletePlannedExerciseWasCalled = false
        lastDeletedMesocycle = nil
        lastActivatedMesocycle = nil
        lastAddedWorkoutDay = nil
        lastAddedPlannedExercise = nil
        lastUpdatedPlannedExercise = nil
        lastDeletedPlannedExercise = nil
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
        lastAddedWorkoutDay = day
        if shouldThrowError { throw errorToThrow }
    }

    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws {
        addPlannedExerciseWasCalled = true
        lastAddedPlannedExercise = planned
        if shouldThrowError { throw errorToThrow }
    }

    func updatePlannedExercise(_ planned: PlannedExercise, name: String, muscle: MuscleGroup, sets: Int, repsMin: Int, repsMax: Int, rir: Int, restSeconds: Int) async throws {
        updatePlannedExerciseWasCalled = true
        lastUpdatedPlannedExercise = planned
        if shouldThrowError { throw errorToThrow }
    }

    func deletePlannedExercise(_ planned: PlannedExercise) async throws {
        deletePlannedExerciseWasCalled = true
        lastDeletedPlannedExercise = planned
        if shouldThrowError { throw errorToThrow }
    }
}

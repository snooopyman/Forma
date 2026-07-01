//
//  WorkoutDayInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class WorkoutDayInteractor: WorkoutDayInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let mesocycleRepository: MesocycleRepositoryProtocol
    private let sessionRepository: WorkoutSessionRepositoryProtocol
    private let sessionService: WorkoutSessionServiceProtocol
    
    // MARK: - Initializers
    
    init(
        mesocycleRepository: MesocycleRepositoryProtocol,
        sessionRepository: WorkoutSessionRepositoryProtocol,
        sessionService: WorkoutSessionServiceProtocol
    ) {
        self.mesocycleRepository = mesocycleRepository
        self.sessionRepository = sessionRepository
        self.sessionService = sessionService
    }
    
    // MARK: - Functions
    
    func fetchInProgressSession() async throws -> WorkoutSession? {
        try await sessionRepository.fetchInProgress()
    }
    
    func deletePlannedExercise(_ planned: PlannedExercise) async throws {
        try await mesocycleRepository.deletePlannedExercise(planned)
    }
    
    func startSession(for workoutDay: WorkoutDay, in mesocycle: Mesocycle) async throws -> WorkoutSession {
        try await sessionService.startSession(for: workoutDay, in: mesocycle)
    }

    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws {
        try await mesocycleRepository.addPlannedExercise(planned, exercise: exercise, to: day)
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
        try await mesocycleRepository.updatePlannedExercise(
            planned,
            name: name,
            muscle: muscle,
            sets: sets,
            repsMin: repsMin,
            repsMax: repsMax,
            rir: rir,
            restSeconds: restSeconds
        )
    }
}

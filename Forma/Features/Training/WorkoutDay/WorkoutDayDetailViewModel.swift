//
//  WorkoutDayDetailViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import os

@Observable
@MainActor
final class WorkoutDayDetailViewModel: AnyObject {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: WorkoutDayInteractorProtocol
    
    // MARK: - Properties
    
    let workoutDay: WorkoutDay
    var inProgressSession: WorkoutSession?
    var isLoading = false
    var isStarting = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var sortedExercises: [PlannedExercise] {
        workoutDay.plannedExercises.sorted { $0.order < $1.order }
    }
    
    var canStartSession: Bool {
        guard let mesocycle = workoutDay.mesocycle else { return false }
        return mesocycle.isActive
        && !mesocycle.isPaused
        && !workoutDay.isRestDay
        && !workoutDay.plannedExercises.isEmpty
    }
    
    // MARK: - Initializers
    
    init(
        workoutDay: WorkoutDay,
        interactor: WorkoutDayInteractorProtocol
    ) {
        self.workoutDay = workoutDay
        self.interactor = interactor
    }
    
    // MARK: - Functions
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            inProgressSession = try await interactor.fetchInProgressSession()
        } catch {
            handleError(error)
        }
    }
    
    func deleteExercise(_ planned: PlannedExercise) async {
        do {
            try await interactor.deletePlannedExercise(planned)
        } catch {
            handleError(error)
        }
    }
    
    func startSession() async throws -> WorkoutSession {
        guard let mesocycle = workoutDay.mesocycle else {
            throw WorkoutDayError.noMesocycle
        }
        isStarting = true
        defer { isStarting = false }
        return try await interactor.startSession(for: workoutDay, in: mesocycle)
    }

    func addPlannedExercise(
        name: String,
        muscle: MuscleGroup,
        equipment: EquipmentType?,
        sets: Int,
        repsMin: Int,
        repsMax: Int,
        rir: Int,
        restSeconds: Int
    ) async {
        let exercise = Exercise(name: name, primaryMuscle: muscle, equipment: equipment?.rawValue ?? "", isCustom: true)
        let planned = PlannedExercise(
            order: workoutDay.plannedExercises.count,
            sets: sets,
            repsMin: repsMin,
            repsMax: repsMax,
            rirTarget: rir,
            restSeconds: restSeconds
        )
        do {
            try await interactor.addPlannedExercise(planned, exercise: exercise, to: workoutDay)
        } catch {
            handleError(error)
        }
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
    ) async {
        do {
            try await interactor.updatePlannedExercise(
                planned,
                name: name,
                muscle: muscle,
                equipment: equipment,
                sets: sets,
                repsMin: repsMin,
                repsMax: repsMax,
                rir: rir,
                restSeconds: restSeconds
            )
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Functions
    
    private func handleError(_ error: Error) {
        Logger.training.error("Error: \(error, privacy: .private)")
        if let trainingError = error as? TrainingError {
            errorMessage = trainingError.errorDescription
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}

enum WorkoutDayError: Error {
    case noMesocycle
}

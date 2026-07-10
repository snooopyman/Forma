//
//  WorkoutDayInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol WorkoutDayInteractorProtocol: Sendable {
    func fetchInProgressSession() async throws -> WorkoutSession?
    func deletePlannedExercise(_ planned: PlannedExercise) async throws
    func startSession(for workoutDay: WorkoutDay, in mesocycle: Mesocycle) async throws -> WorkoutSession
    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws
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
    ) async throws
}

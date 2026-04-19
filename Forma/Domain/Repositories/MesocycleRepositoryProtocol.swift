//
//  MesocycleRepositoryProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation

protocol MesocycleRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Mesocycle]
    func fetchActive() async throws -> Mesocycle?

    func save(_ mesocycle: Mesocycle) async throws
    func delete(_ mesocycle: Mesocycle) async throws

    func setActive(_ mesocycle: Mesocycle) async throws
    func pause(_ mesocycle: Mesocycle) async throws
    func resume(_ mesocycle: Mesocycle) async throws

    func addWorkoutDay(_ day: WorkoutDay, to mesocycle: Mesocycle) async throws
    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws
    func updatePlannedExercise(_ planned: PlannedExercise, name: String, muscle: MuscleGroup, sets: Int, repsMin: Int, repsMax: Int, rir: Int, restSeconds: Int) async throws
    func deletePlannedExercise(_ planned: PlannedExercise) async throws
}

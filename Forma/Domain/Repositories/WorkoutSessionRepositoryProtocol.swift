//
//  WorkoutSessionRepositoryProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation

protocol WorkoutSessionRepositoryProtocol: Sendable {
    func fetchAll(for mesocycle: Mesocycle) async throws -> [WorkoutSession]
    func fetchInProgress() async throws -> WorkoutSession?

    func save(_ session: WorkoutSession) async throws
    func delete(_ session: WorkoutSession) async throws

    func addSet(_ set: LoggedSet, to session: WorkoutSession) async throws
    func deleteSet(_ set: LoggedSet) async throws

    func fetchCompleted(for workoutDay: WorkoutDay) async throws -> [WorkoutSession]
}

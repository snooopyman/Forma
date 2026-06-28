//
//  MesocycleDetailInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol MesocycleDetailInteractorProtocol: Sendable {
    func fetchSessions(for mesocycle: Mesocycle) async throws -> [WorkoutSession]
    func fetchInProgressSession() async throws -> WorkoutSession?
    func activate(_ mesocycle: Mesocycle) async throws
    func pause(_ mesocycle: Mesocycle) async throws
    func resume(_ mesocycle: Mesocycle) async throws
    func addWorkoutDay(_ day: WorkoutDay, to mesocycle: Mesocycle) async throws
}

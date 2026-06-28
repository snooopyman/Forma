//
//  MesocycleDetailInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MesocycleDetailInteractor: MesocycleDetailInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let mesocycleRepository: MesocycleRepositoryProtocol
    private let sessionRepository: WorkoutSessionRepositoryProtocol
    
    // MARK: - Initializers
    
    init(
        mesocycleRepository: MesocycleRepositoryProtocol,
        sessionRepository: WorkoutSessionRepositoryProtocol
    ) {
        self.mesocycleRepository = mesocycleRepository
        self.sessionRepository = sessionRepository
    }
    
    // MARK: - Functions
    
    func fetchSessions(for mesocycle: Mesocycle) async throws -> [WorkoutSession] {
        try await sessionRepository.fetchAll(for: mesocycle)
    }
    
    func fetchInProgressSession() async throws -> WorkoutSession? {
        try await sessionRepository.fetchInProgress()
    }
    
    func activate(_ mesocycle: Mesocycle) async throws {
        try await mesocycleRepository.setActive(mesocycle)
    }
    
    func pause(_ mesocycle: Mesocycle) async throws {
        try await mesocycleRepository.pause(mesocycle)
    }
    
    func resume(_ mesocycle: Mesocycle) async throws {
        try await mesocycleRepository.resume(mesocycle)
    }
    
    func addWorkoutDay(_ day: WorkoutDay, to mesocycle: Mesocycle) async throws {
        try await mesocycleRepository.addWorkoutDay(day, to: mesocycle)
    }
}

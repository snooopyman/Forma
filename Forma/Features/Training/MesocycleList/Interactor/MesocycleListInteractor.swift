//
//  MesocycleListInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MesocycleListInteractor: MesocycleListInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let repository: MesocycleRepositoryProtocol
    
    // MARK: - Initializers
    
    init(repository: MesocycleRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Functions
    
    func fetchMesocycles() async throws -> [Mesocycle] {
        try await repository.fetchAll()
    }
    
    func deleteMesocycle(_ mesocycle: Mesocycle) async throws {
        try await repository.delete(mesocycle)
    }
    
    func setActiveMesocycle(_ mesocycle: Mesocycle) async throws {
        try await repository.setActive(mesocycle)
    }

    func createMesocycle(name: String, startDate: Date, durationWeeks: Int, useFixedDays: Bool) async throws {
        let mesocycle = Mesocycle(
            name: name,
            startDate: startDate,
            durationWeeks: durationWeeks,
            useFixedDays: useFixedDays
        )
        try await repository.save(mesocycle)
    }
}

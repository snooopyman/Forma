//
//  MockMesocycleListInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockMesocycleListInteractor: MesocycleListInteractorProtocol {
    
    // MARK: - Stub Data
    
    var stubbedMesocycles: [Mesocycle] = []
    var shouldThrowOnFetch = false
    var shouldThrowOnDelete = false
    var shouldThrowOnSetActive = false
    
    // MARK: - Functions
    
    func fetchMesocycles() async throws -> [Mesocycle] {
        if shouldThrowOnFetch { throw TrainingError.loadFailed }
        return stubbedMesocycles
    }
    
    func deleteMesocycle(_ mesocycle: Mesocycle) async throws {
        if shouldThrowOnDelete { throw TrainingError.deleteFailed }
        stubbedMesocycles.removeAll { $0.id == mesocycle.id }
    }
    
    func setActiveMesocycle(_ mesocycle: Mesocycle) async throws {
        if shouldThrowOnSetActive { throw TrainingError.setActiveFailed }
        stubbedMesocycles.forEach { $0.isActive = false }
        stubbedMesocycles.first { $0.id == mesocycle.id }?.isActive = true
    }
}

//
//  SpyMesocycleListInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation
@testable import Forma

final class SpyMesocycleListInteractor: MesocycleListInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var fetchMesocyclesWasCalled = false
    private(set) var deleteMesocycleWasCalled = false
    private(set) var setActiveMesocycleWasCalled = false
    private(set) var lastDeletedMesocycle: Mesocycle?
    private(set) var lastActivatedMesocycle: Mesocycle?
    
    // MARK: - Stub Data
    
    var stubbedMesocycles: [Mesocycle] = []
    var shouldThrowError = false
    var errorToThrow: Error = TrainingError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchMesocyclesWasCalled = false
        deleteMesocycleWasCalled = false
        setActiveMesocycleWasCalled = false
        lastDeletedMesocycle = nil
        lastActivatedMesocycle = nil
    }
    
    func fetchMesocycles() async throws -> [Mesocycle] {
        fetchMesocyclesWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedMesocycles
    }
    
    func deleteMesocycle(_ mesocycle: Mesocycle) async throws {
        deleteMesocycleWasCalled = true
        lastDeletedMesocycle = mesocycle
        if shouldThrowError { throw errorToThrow }
        stubbedMesocycles.removeAll { $0.id == mesocycle.id }
    }
    
    func setActiveMesocycle(_ mesocycle: Mesocycle) async throws {
        setActiveMesocycleWasCalled = true
        lastActivatedMesocycle = mesocycle
        if shouldThrowError { throw errorToThrow }
    }
}

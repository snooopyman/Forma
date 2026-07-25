//
//  SpyMuscleVolumeTargetRepository.swift
//  FormaTests
//
//  Created by Armando Cáceres on 25/7/26.
//

import Foundation
@testable import Forma

final class SpyMuscleVolumeTargetRepository: MuscleVolumeTargetRepositoryProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var fetchAllWasCalled = false
    private(set) var saveWasCalled = false
    private(set) var deleteWasCalled = false
    private(set) var savedTargets: [MuscleVolumeTarget] = []
    private(set) var deletedTargets: [MuscleVolumeTarget] = []
    
    // MARK: - Stub Data
    
    var stubbedTargets: [MuscleVolumeTarget] = []
    var shouldThrowError = false
    var failOnSaveCount: Int?
    var errorToThrow: Error = ProgressError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchAllWasCalled = false
        saveWasCalled = false
        deleteWasCalled = false
        savedTargets = []
        deletedTargets = []
    }
    
    func fetchAll() async throws -> [MuscleVolumeTarget] {
        fetchAllWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedTargets
    }
    
    func save(_ target: MuscleVolumeTarget) async throws {
        saveWasCalled = true
        if let failOnSaveCount, savedTargets.count + 1 == failOnSaveCount {
            throw errorToThrow
        }
        if shouldThrowError { throw errorToThrow }
        savedTargets.append(target)
    }
    
    func delete(_ target: MuscleVolumeTarget) async throws {
        deleteWasCalled = true
        deletedTargets.append(target)
        if shouldThrowError { throw errorToThrow }
    }
}

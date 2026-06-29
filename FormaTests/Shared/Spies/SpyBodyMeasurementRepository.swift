//
//  SpyBodyMeasurementRepository.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation
@testable import Forma

final class SpyBodyMeasurementRepository: BodyMeasurementRepositoryProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var fetchAllWasCalled = false
    private(set) var fetchLatestWasCalled = false
    private(set) var saveWasCalled = false
    private(set) var deleteWasCalled = false
    private(set) var lastDeletedMeasurement: BodyMeasurement?
    private(set) var lastSavedMeasurement: BodyMeasurement?
    
    // MARK: - Stub Data
    
    var stubbedMeasurements: [BodyMeasurement] = []
    var stubbedLatest: BodyMeasurement?
    var shouldThrowError = false
    var errorToThrow: Error = ProgressError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchAllWasCalled = false
        fetchLatestWasCalled = false
        saveWasCalled = false
        deleteWasCalled = false
        lastDeletedMeasurement = nil
        lastSavedMeasurement = nil
    }
    
    func fetchAll() async throws -> [BodyMeasurement] {
        fetchAllWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedMeasurements
    }
    
    func fetchLatest() async throws -> BodyMeasurement? {
        fetchLatestWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedLatest
    }
    
    func save(_ measurement: BodyMeasurement) async throws {
        saveWasCalled = true
        lastSavedMeasurement = measurement
        if shouldThrowError { throw errorToThrow }
    }
    
    func update(_ measurement: BodyMeasurement) async throws {
        if shouldThrowError { throw errorToThrow }
    }
    
    func delete(_ measurement: BodyMeasurement) async throws {
        deleteWasCalled = true
        lastDeletedMeasurement = measurement
        if shouldThrowError { throw errorToThrow }
    }
}

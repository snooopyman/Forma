//
//  SpyProgressInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation
@testable import Forma

final class SpyProgressInteractor: ProgressInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var fetchMeasurementsWasCalled = false
    private(set) var deleteMeasurementWasCalled = false
    private(set) var lastDeletedMeasurement: BodyMeasurement?
    
    // MARK: - Stub Data
    
    var stubbedMeasurements: [BodyMeasurement] = []
    var shouldThrowError = false
    var errorToThrow: Error = ProgressError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchMeasurementsWasCalled = false
        deleteMeasurementWasCalled = false
        lastDeletedMeasurement = nil
    }
    
    func fetchMeasurements() async throws -> [BodyMeasurement] {
        fetchMeasurementsWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedMeasurements
    }
    
    func deleteMeasurement(_ measurement: BodyMeasurement) async throws {
        deleteMeasurementWasCalled = true
        lastDeletedMeasurement = measurement
        if shouldThrowError { throw errorToThrow }
        stubbedMeasurements.removeAll { $0.id == measurement.id }
    }
}

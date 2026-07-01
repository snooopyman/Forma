//
//  MockProgressInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockProgressInteractor: ProgressInteractorProtocol {
    
    // MARK: - Stub Data
    
    nonisolated(unsafe) var stubbedMeasurements: [BodyMeasurement] = []
    nonisolated(unsafe) var shouldThrowOnFetch = false
    nonisolated(unsafe) var shouldThrowOnDelete = false
    
    // MARK: - Functions
    
    func fetchMeasurements() async throws -> [BodyMeasurement] {
        if shouldThrowOnFetch { throw ProgressError.loadFailed }
        return stubbedMeasurements
    }
    
    func deleteMeasurement(_ measurement: BodyMeasurement) async throws {
        if shouldThrowOnDelete { throw ProgressError.deleteFailed }
        stubbedMeasurements.removeAll { $0.id == measurement.id }
    }
}

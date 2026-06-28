//
//  ProgressInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class ProgressInteractor: ProgressInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let repository: BodyMeasurementRepositoryProtocol
    
    // MARK: - Initializers
    
    init(repository: BodyMeasurementRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Functions
    
    func fetchMeasurements() async throws -> [BodyMeasurement] {
        try await repository.fetchAll()
    }
    
    func deleteMeasurement(_ measurement: BodyMeasurement) async throws {
        try await repository.delete(measurement)
    }
}

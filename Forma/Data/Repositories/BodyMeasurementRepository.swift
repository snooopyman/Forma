//
//  BodyMeasurementRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

final class BodyMeasurementRepository: BodyMeasurementRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [BodyMeasurement] {
        let descriptor = FetchDescriptor<BodyMeasurement>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchLatest() async throws -> BodyMeasurement? {
        var descriptor = FetchDescriptor<BodyMeasurement>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let results: [BodyMeasurement] = try modelContext.fetch(descriptor)
        return results.first
    }

    func save(_ measurement: BodyMeasurement) async throws {
        modelContext.insert(measurement)
        try modelContext.save()
    }

    func delete(_ measurement: BodyMeasurement) async throws {
        modelContext.delete(measurement)
        try modelContext.save()
    }
}

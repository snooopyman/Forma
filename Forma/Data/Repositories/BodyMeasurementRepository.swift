//
//  BodyMeasurementRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

final class BodyMeasurementRepository: BodyMeasurementRepositoryProtocol {
    
    nonisolated(unsafe) private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() async throws -> [BodyMeasurement] {
        let descriptor = FetchDescriptor<BodyMeasurement>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            throw ProgressError.loadFailed
        }
    }
    
    func fetchLatest() async throws -> BodyMeasurement? {
        var descriptor = FetchDescriptor<BodyMeasurement>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        do {
            let results: [BodyMeasurement] = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            throw ProgressError.loadFailed
        }
    }
    
    func save(_ measurement: BodyMeasurement) async throws {
        modelContext.insert(measurement)
        do {
            try modelContext.save()
        }
        catch {
            throw ProgressError.saveFailed
        }
    }
    
    func update(_ measurement: BodyMeasurement) async throws {
        do {
            try modelContext.save()
        }
        catch {
            throw ProgressError.saveFailed
        }
    }
    
    func delete(_ measurement: BodyMeasurement) async throws {
        modelContext.delete(measurement)
        do {
            try modelContext.save()
        }
        catch {
            throw ProgressError.deleteFailed
        }
    }
}

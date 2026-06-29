//
//  BodyMeasurementRepositoryTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
import Foundation
import SwiftData
@testable import Forma

@Suite("Body Measurement Repository Tests")
@MainActor
struct BodyMeasurementRepositoryTests {
    
    // MARK: - Properties
    
    let sut: BodyMeasurementRepository
    let modelContainer: ModelContainer
    
    // MARK: - Initializers
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: BodyMeasurement.self,
            configurations: config
        )
        sut = BodyMeasurementRepository(modelContext: modelContainer.mainContext)
    }
    
    // MARK: - fetchAll
    
    @Test("fetchAll returns empty when no measurements")
    func fetchAllEmpty() async throws {
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }
    
    @Test("fetchAll returns all saved measurements sorted by date descending")
    func fetchAllSortedDescending() async throws {
        let older = BodyMeasurement(
            date: Date(timeIntervalSinceNow: -7 * 86400),
            weightKg: 80, heightCm: 178, biologicalSex: .male
        )
        let newer = BodyMeasurement(
            date: .now,
            weightKg: 79, heightCm: 178, biologicalSex: .male
        )
        try await sut.save(older)
        try await sut.save(newer)
        let result = try await sut.fetchAll()
        #expect(result.count == 2)
        #expect(result.first?.weightKg == 79)
    }
    
    // MARK: - save / delete round-trip
    
    @Test("save and fetchAll round-trip preserves weightKg")
    func saveAndFetch() async throws {
        let measurement = BodyMeasurement(weightKg: 82.5, heightCm: 180, biologicalSex: .male)
        try await sut.save(measurement)
        let result = try await sut.fetchAll()
        #expect(result.count == 1)
        #expect(result.first?.weightKg == 82.5)
    }
    
    @Test("delete removes measurement from store")
    func deleteMeasurement() async throws {
        let measurement = BodyMeasurement(weightKg: 75, heightCm: 165, biologicalSex: .female)
        try await sut.save(measurement)
        try await sut.delete(measurement)
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }
    
    // MARK: - fetchLatest
    
    @Test("fetchLatest returns nil when no measurements exist")
    func fetchLatestNil() async throws {
        let result = try await sut.fetchLatest()
        #expect(result == nil)
    }
    
    @Test("fetchLatest returns the most recent measurement")
    func fetchLatestReturnsMostRecent() async throws {
        let older = BodyMeasurement(
            date: Date(timeIntervalSinceNow: -14 * 86400),
            weightKg: 83, heightCm: 178, biologicalSex: .male
        )
        let newest = BodyMeasurement(
            date: .now,
            weightKg: 81, heightCm: 178, biologicalSex: .male
        )
        try await sut.save(older)
        try await sut.save(newest)
        let result = try await sut.fetchLatest()
        #expect(result?.weightKg == 81)
    }
    
    // MARK: - update
    
    @Test("update persists changes to weightKg")
    func updateMeasurement() async throws {
        let measurement = BodyMeasurement(weightKg: 90, heightCm: 175, biologicalSex: .male)
        try await sut.save(measurement)
        measurement.weightKg = 88.5
        try await sut.update(measurement)
        let result = try await sut.fetchAll()
        #expect(result.first?.weightKg == 88.5)
    }
}

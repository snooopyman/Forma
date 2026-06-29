//
//  MesocycleRepositoryTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
import SwiftData
@testable import Forma

@Suite("Mesocycle Repository Tests")
@MainActor
struct MesocycleRepositoryTests {
    
    // MARK: - Properties
    
    let sut: MesocycleRepository
    let modelContainer: ModelContainer
    
    // MARK: - Initializers
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Mesocycle.self, WorkoutDay.self, WorkoutSession.self,
            PlannedExercise.self, Exercise.self, LoggedSet.self,
            configurations: config
        )
        sut = MesocycleRepository(modelContext: modelContainer.mainContext)
    }
    
    // MARK: - fetchAll
    
    @Test("fetchAll returns empty when no data")
    func fetchAllEmpty() async throws {
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }
    
    @Test("fetchAll returns all saved mesocycles")
    func fetchAllReturnsSaved() async throws {
        let m1 = Mesocycle(name: "Alpha", durationWeeks: 4)
        let m2 = Mesocycle(name: "Beta", durationWeeks: 6)
        try await sut.save(m1)
        try await sut.save(m2)
        let result = try await sut.fetchAll()
        #expect(result.count == 2)
    }
    
    // MARK: - save / fetchAll round-trip
    
    @Test("save and fetchAll round-trip preserves name and durationWeeks")
    func saveAndFetch() async throws {
        let mesocycle = Mesocycle(name: "Test", durationWeeks: 4)
        try await sut.save(mesocycle)
        let result = try await sut.fetchAll()
        #expect(result.count == 1)
        #expect(result.first?.name == "Test")
        #expect(result.first?.durationWeeks == 4)
    }
    
    // MARK: - delete
    
    @Test("delete removes mesocycle from store")
    func deleteMesocycle() async throws {
        let mesocycle = Mesocycle(name: "ToDelete", durationWeeks: 4)
        try await sut.save(mesocycle)
        try await sut.delete(mesocycle)
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }
    
    // MARK: - fetchActive
    
    @Test("fetchActive returns nil when none is active")
    func fetchActiveNil() async throws {
        let m = Mesocycle(name: "Inactive", durationWeeks: 4, isActive: false)
        try await sut.save(m)
        let result = try await sut.fetchActive()
        #expect(result == nil)
    }
    
    @Test("fetchActive returns the active mesocycle")
    func fetchActiveReturnsActive() async throws {
        let m = Mesocycle(name: "Active", durationWeeks: 4, isActive: true)
        try await sut.save(m)
        let result = try await sut.fetchActive()
        #expect(result?.name == "Active")
    }
    
    // MARK: - setActive
    
    @Test("setActive marks only one mesocycle as active")
    func setActiveExclusive() async throws {
        let m1 = Mesocycle(name: "First", durationWeeks: 4)
        let m2 = Mesocycle(name: "Second", durationWeeks: 4)
        try await sut.save(m1)
        try await sut.save(m2)
        try await sut.setActive(m1)
        try await sut.setActive(m2)
        let all = try await sut.fetchAll()
        let activeCount = all.filter { $0.isActive }.count
        #expect(activeCount == 1)
        #expect(all.first { $0.isActive }?.name == "Second")
    }
    
    // MARK: - pause / resume
    
    @Test("pause sets pausedAt and isPaused is true")
    func pauseMesocycle() async throws {
        let m = Mesocycle(name: "Pauseable", durationWeeks: 4)
        try await sut.save(m)
        try await sut.pause(m)
        #expect(m.isPaused == true)
        #expect(m.pausedAt != nil)
    }
    
    @Test("resume sets resumedAt and isPaused is false")
    func resumeMesocycle() async throws {
        let m = Mesocycle(name: "Resumeable", durationWeeks: 4)
        try await sut.save(m)
        try await sut.pause(m)
        try await sut.resume(m)
        #expect(m.isPaused == false)
        #expect(m.resumedAt != nil)
    }
}

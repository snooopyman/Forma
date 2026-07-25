//
//  MuscleVolumeTargetRepositoryTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 25/7/26.
//

import Testing
import Foundation
import SwiftData
@testable import Forma

@Suite("Muscle Volume Target Repository Tests")
@MainActor
struct MuscleVolumeTargetRepositoryTests {
    
    // MARK: - Properties
    
    let sut: MuscleVolumeTargetRepository
    let modelContainer: ModelContainer
    
    // MARK: - Initializers
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: MuscleVolumeTarget.self,
            configurations: config
        )
        sut = MuscleVolumeTargetRepository(modelContext: modelContainer.mainContext)
    }
    
    @Test("fetchAll returns empty when no targets")
    func fetchAllEmpty() async throws {
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }
    
    @Test("save and fetchAll round-trip preserves MEV/MAV/MRV")
    func saveAndFetch() async throws {
        let target = MuscleVolumeTarget(muscleGroup: .chest, mevSets: 8, mavSets: 16, mrvSets: 22)
        try await sut.save(target)
        let result = try await sut.fetchAll()
        #expect(result.count == 1)
        #expect(result.first?.muscleGroup == .chest)
        #expect(result.first?.mavSets == 16)
    }
    
    @Test("save persists mutations to an already-saved target")
    func mutateAndSave() async throws {
        let target = MuscleVolumeTarget(muscleGroup: .back, mevSets: 10, mavSets: 18, mrvSets: 25)
        try await sut.save(target)
        target.mavSets = 20
        try await sut.save(target)
        let result = try await sut.fetchAll()
        #expect(result.first?.mavSets == 20)
    }
    
    @Test("delete removes target from store")
    func deleteTarget() async throws {
        let target = MuscleVolumeTarget(muscleGroup: .glutes, mevSets: 4, mavSets: 10, mrvSets: 16)
        try await sut.save(target)
        try await sut.delete(target)
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }
}

//
//  WorkoutSessionRepositoryTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
import Foundation
import SwiftData
@testable import Forma

@Suite("Workout Session Repository Tests")
@MainActor
struct WorkoutSessionRepositoryTests {
    
    // MARK: - Properties
    
    let sut: WorkoutSessionRepository
    let modelContainer: ModelContainer
    
    // MARK: - Initializers
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Mesocycle.self, WorkoutDay.self, WorkoutSession.self,
            PlannedExercise.self, Exercise.self, LoggedSet.self,
            configurations: config
        )
        sut = WorkoutSessionRepository(modelContext: modelContainer.mainContext)
    }
    
    // MARK: - fetchAll(for:)
    
    @Test("fetchAll returns empty when no sessions for mesocycle")
    func fetchAllEmpty() async throws {
        let mesocycle = Mesocycle(name: "Cycle", durationWeeks: 4)
        modelContainer.mainContext.insert(mesocycle)
        try modelContainer.mainContext.save()
        let result = try await sut.fetchAll(for: mesocycle)
        #expect(result.isEmpty)
    }
    
    @Test("fetchAll returns sessions belonging to the given mesocycle")
    func fetchAllForMesocycle() async throws {
        let mesocycle = Mesocycle(name: "Cycle", durationWeeks: 4)
        modelContainer.mainContext.insert(mesocycle)
        let session = WorkoutSession(sessionType: .planned)
        session.mesocycle = mesocycle
        try await sut.save(session)
        let result = try await sut.fetchAll(for: mesocycle)
        #expect(result.count == 1)
    }
    
    // MARK: - fetchInProgress
    
    @Test("fetchInProgress returns nil when all sessions are completed")
    func fetchInProgressNilWhenCompleted() async throws {
        let session = WorkoutSession(sessionType: .planned)
        session.completedAt = .now
        try await sut.save(session)
        let result = try await sut.fetchInProgress()
        #expect(result == nil)
    }
    
    @Test("fetchInProgress returns in-progress session")
    func fetchInProgressReturnsOpenSession() async throws {
        let session = WorkoutSession(sessionType: .planned)
        try await sut.save(session)
        let result = try await sut.fetchInProgress()
        #expect(result != nil)
        #expect(result?.completedAt == nil)
    }
    
    // MARK: - save / delete
    
    @Test("save and delete round-trip")
    func saveAndDelete() async throws {
        let session = WorkoutSession(sessionType: .freeStyle)
        try await sut.save(session)
        try await sut.delete(session)
        let mesocycle = Mesocycle(name: "Cycle", durationWeeks: 4)
        modelContainer.mainContext.insert(mesocycle)
        let result = try await sut.fetchAll(for: mesocycle)
        #expect(result.isEmpty)
    }
    
    // MARK: - addSet / deleteSet
    
    @Test("addSet appends a LoggedSet to the session")
    func addSet() async throws {
        let session = WorkoutSession(sessionType: .planned)
        try await sut.save(session)
        let set = LoggedSet(order: 1, exerciseName: "Squat", weightKg: 100, reps: 5)
        try await sut.addSet(set, to: session)
        #expect(session.loggedSets.count == 1)
        #expect(session.loggedSets.first?.exerciseName == "Squat")
    }
    
    @Test("deleteSet removes the set from the store")
    func deleteSet() async throws {
        let session = WorkoutSession(sessionType: .planned)
        try await sut.save(session)
        let set = LoggedSet(order: 1, exerciseName: "Bench", weightKg: 80, reps: 8)
        try await sut.addSet(set, to: session)
        try await sut.deleteSet(set)
        #expect(session.loggedSets.isEmpty)
    }
}

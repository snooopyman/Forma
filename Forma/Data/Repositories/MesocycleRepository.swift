//
//  MesocycleRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

final class MesocycleRepository: MesocycleRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [Mesocycle] {
        let descriptor = FetchDescriptor<Mesocycle>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchActive() async throws -> Mesocycle? {
        var descriptor = FetchDescriptor<Mesocycle>(
            predicate: #Predicate { $0.isActive }
        )
        descriptor.fetchLimit = 1
        let results: [Mesocycle] = try modelContext.fetch(descriptor)
        return results.first
    }

    func save(_ mesocycle: Mesocycle) async throws {
        modelContext.insert(mesocycle)
        try modelContext.save()
    }

    func delete(_ mesocycle: Mesocycle) async throws {
        modelContext.delete(mesocycle)
        try modelContext.save()
    }

    func setActive(_ mesocycle: Mesocycle) async throws {
        let all = try await fetchAll()
        all.forEach { $0.isActive = false }
        mesocycle.isActive = true
        try modelContext.save()
    }

    func pause(_ mesocycle: Mesocycle) async throws {
        mesocycle.pausedAt = .now
        try modelContext.save()
    }

    func resume(_ mesocycle: Mesocycle) async throws {
        mesocycle.resumedAt = .now
        try modelContext.save()
    }

    func addWorkoutDay(_ day: WorkoutDay, to mesocycle: Mesocycle) async throws {
        modelContext.insert(day)
        day.mesocycle = mesocycle
        try modelContext.save()
    }

    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws {
        modelContext.insert(exercise)
        modelContext.insert(planned)
        planned.exercise = exercise
        planned.workoutDay = day
        try modelContext.save()
    }

    func deletePlannedExercise(_ planned: PlannedExercise) async throws {
        modelContext.delete(planned)
        try modelContext.save()
    }
}

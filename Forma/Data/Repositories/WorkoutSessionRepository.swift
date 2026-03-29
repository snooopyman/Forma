//
//  WorkoutSessionRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

final class WorkoutSessionRepository: WorkoutSessionRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll(for mesocycle: Mesocycle) async throws -> [WorkoutSession] {
        let mesocycleID = mesocycle.id
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.mesocycle?.id == mesocycleID },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchInProgress() async throws -> WorkoutSession? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.completedAt == nil }
        )
        descriptor.fetchLimit = 1
        let results: [WorkoutSession] = try modelContext.fetch(descriptor)
        return results.first
    }

    func save(_ session: WorkoutSession) async throws {
        modelContext.insert(session)
        try modelContext.save()
    }

    func delete(_ session: WorkoutSession) async throws {
        modelContext.delete(session)
        try modelContext.save()
    }

    func addSet(_ set: LoggedSet, to session: WorkoutSession) async throws {
        session.loggedSets.append(set)
        try modelContext.save()
    }

    func deleteSet(_ set: LoggedSet) async throws {
        modelContext.delete(set)
        try modelContext.save()
    }
}

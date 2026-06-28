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
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            throw TrainingError.loadFailed
        }
    }
    
    func fetchInProgress() async throws -> WorkoutSession? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.completedAt == nil }
        )
        descriptor.fetchLimit = 1
        do {
            let results: [WorkoutSession] = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            throw TrainingError.loadFailed
        }
    }
    
    func save(_ session: WorkoutSession) async throws {
        modelContext.insert(session)
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.saveFailed
        }
    }
    
    func delete(_ session: WorkoutSession) async throws {
        modelContext.delete(session)
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.deleteFailed
        }
    }
    
    func addSet(_ set: LoggedSet, to session: WorkoutSession) async throws {
        session.loggedSets.append(set)
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.logSetFailed
        }
    }
    
    func deleteSet(_ set: LoggedSet) async throws {
        modelContext.delete(set)
        do {
            try modelContext.save()
        }
        catch { throw TrainingError.deleteFailed
        }
    }
    
    func fetchCompleted(for workoutDay: WorkoutDay) async throws -> [WorkoutSession] {
        let workoutDayID = workoutDay.id
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.workoutDay?.id == workoutDayID && $0.completedAt != nil },
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            throw TrainingError.loadFailed
        }
    }
}

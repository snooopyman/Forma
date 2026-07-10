//
//  MesocycleRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

final class MesocycleRepository: MesocycleRepositoryProtocol {
    
    nonisolated(unsafe) private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() async throws -> [Mesocycle] {
        let descriptor = FetchDescriptor<Mesocycle>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            throw TrainingError.loadFailed
        }
    }
    
    func fetchActive() async throws -> Mesocycle? {
        var descriptor = FetchDescriptor<Mesocycle>(
            predicate: #Predicate { $0.isActive }
        )
        descriptor.fetchLimit = 1
        do {
            let results: [Mesocycle] = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            throw TrainingError.loadFailed
        }
    }
    
    func save(_ mesocycle: Mesocycle) async throws {
        modelContext.insert(mesocycle)
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.saveFailed
        }
    }
    
    func delete(_ mesocycle: Mesocycle) async throws {
        modelContext.delete(mesocycle)
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.deleteFailed
        }
    }
    
    func setActive(_ mesocycle: Mesocycle) async throws {
        let all = try await fetchAll()
        all.forEach { $0.isActive = false }
        mesocycle.isActive = true
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.setActiveFailed
        }
    }
    
    func pause(_ mesocycle: Mesocycle) async throws {
        mesocycle.pausedAt = .now
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.saveFailed
        }
    }
    
    func resume(_ mesocycle: Mesocycle) async throws {
        mesocycle.resumedAt = .now
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.saveFailed
        }
    }
    
    func addWorkoutDay(_ day: WorkoutDay, to mesocycle: Mesocycle) async throws {
        modelContext.insert(day)
        day.mesocycle = mesocycle
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.saveFailed
        }
    }
    
    func addPlannedExercise(_ planned: PlannedExercise, exercise: Exercise, to day: WorkoutDay) async throws {
        modelContext.insert(exercise)
        modelContext.insert(planned)
        planned.exercise = exercise
        planned.workoutDay = day
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.saveFailed
        }
    }
    
    func updatePlannedExercise(_ planned: PlannedExercise, name: String, muscle: MuscleGroup, equipment: EquipmentType?, sets: Int, repsMin: Int, repsMax: Int, rir: Int, restSeconds: Int) async throws {
        planned.exercise?.name = name
        planned.exercise?.primaryMuscle = muscle
        planned.exercise?.equipmentType = equipment
        planned.sets = sets
        planned.repsMin = repsMin
        planned.repsMax = repsMax
        planned.rirTarget = rir
        planned.restSeconds = restSeconds
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.saveFailed
        }
    }
    
    func deletePlannedExercise(_ planned: PlannedExercise) async throws {
        modelContext.delete(planned)
        do {
            try modelContext.save()
        }
        catch {
            throw TrainingError.deleteFailed
        }
    }
}

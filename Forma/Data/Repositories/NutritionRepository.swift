//
//  NutritionRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

final class NutritionRepository: NutritionRepositoryProtocol {
    
    nonisolated(unsafe) private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAllPlans() async throws -> [NutritionPlan] {
        let descriptor = FetchDescriptor<NutritionPlan>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            throw NutritionError.loadFailed
        }
    }
    
    func fetchActivePlan() async throws -> NutritionPlan? {
        var descriptor = FetchDescriptor<NutritionPlan>(
            predicate: #Predicate { $0.isActive }
        )
        descriptor.fetchLimit = 1
        do {
            let results: [NutritionPlan] = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            throw NutritionError.loadFailed
        }
    }
    
    func savePlan(_ plan: NutritionPlan) async throws {
        modelContext.insert(plan)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.saveFailed
        }
    }
    
    func deletePlan(_ plan: NutritionPlan) async throws {
        modelContext.delete(plan)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.deleteFailed
        }
    }
    
    func save() async throws {
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.saveFailed
        }
    }
    
    func setActivePlan(_ plan: NutritionPlan) async throws {
        let all = try await fetchAllPlans()
        all.forEach { $0.isActive = false }
        plan.isActive = true
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.saveFailed
        }
    }
    
    func insertMeal(_ meal: Meal) async throws {
        modelContext.insert(meal)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.saveFailed
        }
    }
    
    func deleteMeal(_ meal: Meal) async throws {
        modelContext.delete(meal)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.deleteFailed
        }
    }
    
    func insertMealOption(_ option: MealOption) async throws {
        modelContext.insert(option)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.saveFailed
        }
    }
    
    func deleteMealOption(_ option: MealOption) async throws {
        modelContext.delete(option)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.deleteFailed
        }
    }
    
    func insertMealOptionItem(_ item: MealOptionItem) async throws {
        modelContext.insert(item)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.saveFailed
        }
    }
    
    func deleteMealOptionItem(_ item: MealOptionItem) async throws {
        modelContext.delete(item)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.deleteFailed
        }
    }
    
    func fetchLog(for date: Date) async throws -> DailyNutritionLog? {
        let start = Calendar.current.startOfDay(for: date)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return nil }
        var descriptor = FetchDescriptor<DailyNutritionLog>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        descriptor.fetchLimit = 1
        do {
            let results: [DailyNutritionLog] = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            throw NutritionError.loadFailed
        }
    }
    
    func saveLog(_ log: DailyNutritionLog) async throws {
        modelContext.insert(log)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.saveFailed
        }
    }
    
    func addMealLog(_ mealLog: MealLog, to dailyLog: DailyNutritionLog) async throws {
        modelContext.insert(mealLog)
        mealLog.dailyLog = dailyLog
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.saveFailed
        }
    }
    
    func removeMealLog(_ mealLog: MealLog) async throws {
        modelContext.delete(mealLog)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.deleteFailed
        }
    }
}

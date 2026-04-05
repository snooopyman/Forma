//
//  NutritionRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

final class NutritionRepository: NutritionRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAllPlans() async throws -> [NutritionPlan] {
        let descriptor = FetchDescriptor<NutritionPlan>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchActivePlan() async throws -> NutritionPlan? {
        var descriptor = FetchDescriptor<NutritionPlan>(
            predicate: #Predicate { $0.isActive }
        )
        descriptor.fetchLimit = 1
        let results: [NutritionPlan] = try modelContext.fetch(descriptor)
        return results.first
    }

    func savePlan(_ plan: NutritionPlan) async throws {
        modelContext.insert(plan)
        try modelContext.save()
    }

    func deletePlan(_ plan: NutritionPlan) async throws {
        modelContext.delete(plan)
        try modelContext.save()
    }

    func save() async throws {
        try modelContext.save()
    }

    func setActivePlan(_ plan: NutritionPlan) async throws {
        let all = try await fetchAllPlans()
        all.forEach { $0.isActive = false }
        plan.isActive = true
        try modelContext.save()
    }

    func insertMeal(_ meal: Meal) async throws {
        modelContext.insert(meal)
        try modelContext.save()
    }

    func deleteMeal(_ meal: Meal) async throws {
        modelContext.delete(meal)
        try modelContext.save()
    }

    func insertMealOption(_ option: MealOption) async throws {
        modelContext.insert(option)
        try modelContext.save()
    }

    func deleteMealOption(_ option: MealOption) async throws {
        modelContext.delete(option)
        try modelContext.save()
    }

    func insertMealOptionItem(_ item: MealOptionItem) async throws {
        modelContext.insert(item)
        try modelContext.save()
    }

    func deleteMealOptionItem(_ item: MealOptionItem) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func fetchLog(for date: Date) async throws -> DailyNutritionLog? {
        let start = Calendar.current.startOfDay(for: date)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return nil }
        var descriptor = FetchDescriptor<DailyNutritionLog>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        descriptor.fetchLimit = 1
        let results: [DailyNutritionLog] = try modelContext.fetch(descriptor)
        return results.first
    }

    func saveLog(_ log: DailyNutritionLog) async throws {
        modelContext.insert(log)
        try modelContext.save()
    }

    func addMealLog(_ mealLog: MealLog, to dailyLog: DailyNutritionLog) async throws {
        modelContext.insert(mealLog)
        mealLog.dailyLog = dailyLog
        try modelContext.save()
    }

    func removeMealLog(_ mealLog: MealLog) async throws {
        modelContext.delete(mealLog)
        try modelContext.save()
    }
}

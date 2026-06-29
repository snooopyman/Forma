//
//  NutritionRepositoryTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
import Foundation
import SwiftData
@testable import Forma

@Suite("Nutrition Repository Tests")
@MainActor
struct NutritionRepositoryTests {
    
    // MARK: - Properties
    
    let sut: NutritionRepository
    let modelContainer: ModelContainer
    
    // MARK: - Initializers
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: NutritionPlan.self, Meal.self, MealOption.self, MealOptionItem.self,
            DailyNutritionLog.self, MealLog.self, FoodItem.self,
            configurations: config
        )
        sut = NutritionRepository(modelContext: modelContainer.mainContext)
    }
    
    // MARK: - fetchAllPlans
    
    @Test("fetchAllPlans returns empty when no plans")
    func fetchAllPlansEmpty() async throws {
        let result = try await sut.fetchAllPlans()
        #expect(result.isEmpty)
    }
    
    @Test("fetchAllPlans returns all saved plans")
    func fetchAllPlansReturnsSaved() async throws {
        let p1 = NutritionPlan(name: "Cut", targetCalories: 1800, targetProteinG: 180, targetCarbsG: 120, targetFatG: 60)
        let p2 = NutritionPlan(name: "Bulk", targetCalories: 2800, targetProteinG: 200, targetCarbsG: 300, targetFatG: 90)
        try await sut.savePlan(p1)
        try await sut.savePlan(p2)
        let result = try await sut.fetchAllPlans()
        #expect(result.count == 2)
    }
    
    // MARK: - savePlan / deletePlan
    
    @Test("savePlan and fetchAllPlans round-trip preserves name")
    func savePlanAndFetch() async throws {
        let plan = NutritionPlan(name: "Maintenance", targetCalories: 2200, targetProteinG: 165, targetCarbsG: 220, targetFatG: 73)
        try await sut.savePlan(plan)
        let result = try await sut.fetchAllPlans()
        #expect(result.count == 1)
        #expect(result.first?.name == "Maintenance")
    }
    
    @Test("deletePlan removes plan from store")
    func deletePlan() async throws {
        let plan = NutritionPlan(name: "ToDelete", targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 67)
        try await sut.savePlan(plan)
        try await sut.deletePlan(plan)
        let result = try await sut.fetchAllPlans()
        #expect(result.isEmpty)
    }
    
    // MARK: - fetchActivePlan
    
    @Test("fetchActivePlan returns nil when none is active")
    func fetchActivePlanNil() async throws {
        let plan = NutritionPlan(name: "Inactive", isActive: false, targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 67)
        try await sut.savePlan(plan)
        let result = try await sut.fetchActivePlan()
        #expect(result == nil)
    }
    
    @Test("fetchActivePlan returns the active plan")
    func fetchActivePlanReturnsActive() async throws {
        let plan = NutritionPlan(name: "Active", isActive: true, targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 67)
        try await sut.savePlan(plan)
        let result = try await sut.fetchActivePlan()
        #expect(result?.name == "Active")
    }
    
    // MARK: - setActivePlan
    
    @Test("setActivePlan marks only one plan as active")
    func setActivePlanExclusive() async throws {
        let p1 = NutritionPlan(name: "First", targetCalories: 1800, targetProteinG: 150, targetCarbsG: 150, targetFatG: 60)
        let p2 = NutritionPlan(name: "Second", targetCalories: 2000, targetProteinG: 160, targetCarbsG: 200, targetFatG: 67)
        try await sut.savePlan(p1)
        try await sut.savePlan(p2)
        try await sut.setActivePlan(p1)
        try await sut.setActivePlan(p2)
        let all = try await sut.fetchAllPlans()
        let activeCount = all.filter { $0.isActive }.count
        #expect(activeCount == 1)
        #expect(all.first { $0.isActive }?.name == "Second")
    }
    
    // MARK: - fetchLog
    
    @Test("fetchLog returns nil when no log exists for date")
    func fetchLogNil() async throws {
        let result = try await sut.fetchLog(for: .now)
        #expect(result == nil)
    }
    
    @Test("fetchLog returns log saved for the same calendar day")
    func fetchLogForDate() async throws {
        let today = Calendar.current.startOfDay(for: .now)
        let log = DailyNutritionLog(date: today)
        try await sut.saveLog(log)
        let result = try await sut.fetchLog(for: .now)
        #expect(result != nil)
    }
    
    // MARK: - insertMeal / deleteMeal
    
    @Test("insertMeal adds a meal to the store")
    func insertMeal() async throws {
        let plan = NutritionPlan(name: "Plan", targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 67)
        try await sut.savePlan(plan)
        let meal = Meal(name: "Breakfast", mealType: .breakfast, order: 1)
        meal.nutritionPlan = plan
        try await sut.insertMeal(meal)
        #expect(plan.meals.count == 1)
    }
    
    @Test("deleteMeal removes meal from the plan")
    func deleteMeal() async throws {
        let plan = NutritionPlan(name: "Plan", targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 67)
        try await sut.savePlan(plan)
        let meal = Meal(name: "Lunch", mealType: .lunch, order: 2)
        meal.nutritionPlan = plan
        try await sut.insertMeal(meal)
        try await sut.deleteMeal(meal)
        #expect(plan.meals.isEmpty)
    }
}

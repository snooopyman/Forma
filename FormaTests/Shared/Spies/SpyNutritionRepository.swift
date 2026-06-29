//
//  SpyNutritionRepository.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation
@testable import Forma

final class SpyNutritionRepository: NutritionRepositoryProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var fetchActivePlanWasCalled = false
    private(set) var fetchLogWasCalled = false
    private(set) var saveLogWasCalled = false
    private(set) var addMealLogWasCalled = false
    private(set) var removeMealLogWasCalled = false
    private(set) var lastSavedLog: DailyNutritionLog?
    private(set) var lastAddedMealLog: MealLog?
    private(set) var lastRemovedMealLog: MealLog?
    
    // MARK: - Stub Data
    
    var stubbedActivePlan: NutritionPlan?
    var stubbedLog: DailyNutritionLog?
    var shouldThrowError = false
    var errorToThrow: Error = NutritionError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchActivePlanWasCalled = false
        fetchLogWasCalled = false
        saveLogWasCalled = false
        addMealLogWasCalled = false
        removeMealLogWasCalled = false
        lastSavedLog = nil
        lastAddedMealLog = nil
        lastRemovedMealLog = nil
    }
    
    func fetchActivePlan() async throws -> NutritionPlan? {
        fetchActivePlanWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedActivePlan
    }
    
    func fetchLog(for date: Date) async throws -> DailyNutritionLog? {
        fetchLogWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedLog
    }
    
    func saveLog(_ log: DailyNutritionLog) async throws {
        saveLogWasCalled = true
        lastSavedLog = log
        if shouldThrowError { throw errorToThrow }
    }
    
    func addMealLog(_ mealLog: MealLog, to dailyLog: DailyNutritionLog) async throws {
        addMealLogWasCalled = true
        lastAddedMealLog = mealLog
        if shouldThrowError { throw errorToThrow }
    }
    
    func removeMealLog(_ mealLog: MealLog) async throws {
        removeMealLogWasCalled = true
        lastRemovedMealLog = mealLog
        if shouldThrowError { throw errorToThrow }
    }
    
    func fetchAllPlans() async throws -> [NutritionPlan] { [] }
    func savePlan(_ plan: NutritionPlan) async throws { }
    func deletePlan(_ plan: NutritionPlan) async throws { }
    func save() async throws { }
    func setActivePlan(_ plan: NutritionPlan) async throws { }
    func insertMeal(_ meal: Meal) async throws { }
    func deleteMeal(_ meal: Meal) async throws { }
    func insertMealOption(_ option: MealOption) async throws { }
    func deleteMealOption(_ option: MealOption) async throws { }
    func insertMealOptionItem(_ item: MealOptionItem) async throws { }
    func deleteMealOptionItem(_ item: MealOptionItem) async throws { }
}

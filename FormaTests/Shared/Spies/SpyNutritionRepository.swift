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
    private(set) var savePlanWasCalled = false
    private(set) var setActivePlanWasCalled = false
    private(set) var saveWasCalled = false
    private(set) var insertMealWasCalled = false
    private(set) var deleteMealWasCalled = false
    private(set) var insertMealOptionWasCalled = false
    private(set) var deleteMealOptionWasCalled = false
    private(set) var insertMealOptionItemWasCalled = false
    private(set) var deleteMealOptionItemWasCalled = false
    private(set) var lastSavedLog: DailyNutritionLog?
    private(set) var lastAddedMealLog: MealLog?
    private(set) var lastRemovedMealLog: MealLog?
    private(set) var lastSavedPlan: NutritionPlan?
    private(set) var lastInsertedMeal: Meal?
    private(set) var lastDeletedMeal: Meal?
    private(set) var lastInsertedOption: MealOption?
    private(set) var lastDeletedOption: MealOption?
    private(set) var lastInsertedItem: MealOptionItem?
    private(set) var lastDeletedItem: MealOptionItem?

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
        savePlanWasCalled = false
        setActivePlanWasCalled = false
        saveWasCalled = false
        insertMealWasCalled = false
        deleteMealWasCalled = false
        insertMealOptionWasCalled = false
        deleteMealOptionWasCalled = false
        insertMealOptionItemWasCalled = false
        deleteMealOptionItemWasCalled = false
        lastSavedLog = nil
        lastAddedMealLog = nil
        lastRemovedMealLog = nil
        lastSavedPlan = nil
        lastInsertedMeal = nil
        lastDeletedMeal = nil
        lastInsertedOption = nil
        lastDeletedOption = nil
        lastInsertedItem = nil
        lastDeletedItem = nil
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

    func savePlan(_ plan: NutritionPlan) async throws {
        savePlanWasCalled = true
        lastSavedPlan = plan
        if shouldThrowError { throw errorToThrow }
    }

    func deletePlan(_ plan: NutritionPlan) async throws { }

    func save() async throws {
        saveWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }

    func setActivePlan(_ plan: NutritionPlan) async throws {
        setActivePlanWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }

    func insertMeal(_ meal: Meal) async throws {
        insertMealWasCalled = true
        lastInsertedMeal = meal
        if shouldThrowError { throw errorToThrow }
    }

    func deleteMeal(_ meal: Meal) async throws {
        deleteMealWasCalled = true
        lastDeletedMeal = meal
        if shouldThrowError { throw errorToThrow }
    }

    func insertMealOption(_ option: MealOption) async throws {
        insertMealOptionWasCalled = true
        lastInsertedOption = option
        if shouldThrowError { throw errorToThrow }
    }

    func deleteMealOption(_ option: MealOption) async throws {
        deleteMealOptionWasCalled = true
        lastDeletedOption = option
        if shouldThrowError { throw errorToThrow }
    }

    func insertMealOptionItem(_ item: MealOptionItem) async throws {
        insertMealOptionItemWasCalled = true
        lastInsertedItem = item
        if shouldThrowError { throw errorToThrow }
    }

    func deleteMealOptionItem(_ item: MealOptionItem) async throws {
        deleteMealOptionItemWasCalled = true
        lastDeletedItem = item
        if shouldThrowError { throw errorToThrow }
    }
}

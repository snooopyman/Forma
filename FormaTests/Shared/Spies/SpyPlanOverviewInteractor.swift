//
//  SpyPlanOverviewInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation
@testable import Forma

final class SpyPlanOverviewInteractor: PlanOverviewInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var fetchActivePlanWasCalled = false
    private(set) var fetchLogWasCalled = false
    private(set) var computeSummaryWasCalled = false
    private(set) var saveLogWasCalled = false
    private(set) var addMealLogWasCalled = false
    private(set) var removeMealLogWasCalled = false
    private(set) var lastRemovedMealLog: MealLog?
    private(set) var lastAddedMealLog: MealLog?
    
    // MARK: - Stub Data
    
    var stubbedPlan: NutritionPlan?
    var stubbedLog: DailyNutritionLog?
    var stubbedSummary = DailyMacroSummary(consumedCalories: 0, consumedProteinG: 0, consumedCarbsG: 0, consumedFatG: 0, targetCalories: 0, targetProteinG: 0, targetCarbsG: 0, targetFatG: 0)
    var shouldThrowError = false
    var errorToThrow: Error = NutritionError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchActivePlanWasCalled = false
        fetchLogWasCalled = false
        computeSummaryWasCalled = false
        saveLogWasCalled = false
        addMealLogWasCalled = false
        removeMealLogWasCalled = false
        lastRemovedMealLog = nil
        lastAddedMealLog = nil
    }
    
    func fetchActivePlan() async throws -> NutritionPlan? {
        fetchActivePlanWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedPlan
    }
    
    func fetchLog(for date: Date) async throws -> DailyNutritionLog? {
        fetchLogWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedLog
    }
    
    func computeSummary(plan: NutritionPlan, log: DailyNutritionLog?) -> DailyMacroSummary {
        computeSummaryWasCalled = true
        return stubbedSummary
    }
    
    func saveLog(_ log: DailyNutritionLog) async throws {
        saveLogWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
    
    func addMealLog(_ mealLog: MealLog, to log: DailyNutritionLog) async throws {
        addMealLogWasCalled = true
        lastAddedMealLog = mealLog
        if shouldThrowError { throw errorToThrow }
    }
    
    func removeMealLog(_ mealLog: MealLog) async throws {
        removeMealLogWasCalled = true
        lastRemovedMealLog = mealLog
        if shouldThrowError { throw errorToThrow }
    }
}

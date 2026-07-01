//
//  MockPlanOverviewInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockPlanOverviewInteractor: PlanOverviewInteractorProtocol {

    // MARK: - Stub Data

    nonisolated(unsafe) var stubbedPlan: NutritionPlan?
    nonisolated(unsafe) var stubbedLog: DailyNutritionLog?
    nonisolated(unsafe) var stubbedSummary: DailyMacroSummary?
    nonisolated(unsafe) var shouldThrowOnLoad = false
    nonisolated(unsafe) var shouldThrowOnMutate = false

    // MARK: - Functions

    func fetchActivePlan() async throws -> NutritionPlan? {
        if shouldThrowOnLoad { throw NutritionError.loadFailed }
        return stubbedPlan
    }

    func fetchLog(for date: Date) async throws -> DailyNutritionLog? {
        if shouldThrowOnLoad { throw NutritionError.loadFailed }
        return stubbedLog
    }

    func computeSummary(plan: NutritionPlan, log: DailyNutritionLog?) -> DailyMacroSummary {
        stubbedSummary ?? DailyMacroSummary(
            consumedCalories: 0, consumedProteinG: 0, consumedCarbsG: 0, consumedFatG: 0,
            targetCalories: plan.targetCalories, targetProteinG: plan.targetProteinG,
            targetCarbsG: plan.targetCarbsG, targetFatG: plan.targetFatG
        )
    }

    func saveLog(_ log: DailyNutritionLog) async throws {
        if shouldThrowOnMutate { throw NutritionError.saveFailed }
    }

    func addMealLog(_ mealLog: MealLog, to log: DailyNutritionLog) async throws {
        if shouldThrowOnMutate { throw NutritionError.saveFailed }
    }

    func removeMealLog(_ mealLog: MealLog) async throws {
        if shouldThrowOnMutate { throw NutritionError.deleteFailed }
    }
}

//
//  PlanOverviewTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
import Foundation
@testable import Forma

extension PlanOverviewTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: PlanOverviewInteractor

        // MARK: - Spies

        let spy: SpyNutritionRepository

        // MARK: - Initializers

        init() {
            spy = SpyNutritionRepository()
            sut = PlanOverviewInteractor(nutritionRepository: spy, macroService: MacroTrackingService())
        }

        @Test("fetchActivePlan delegates to repository")
        func fetchActivePlanTracked() async throws {
            let plan = NutritionPlan(name: "Plan", targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 60)
            spy.stubbedActivePlan = plan
            let result = try await sut.fetchActivePlan()
            #expect(spy.fetchActivePlanWasCalled == true)
            #expect(result?.id == plan.id)
        }

        @Test("fetchActivePlan propagates error")
        func fetchActivePlanPropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.loadFailed
            await #expect(throws: NutritionError.self) {
                _ = try await sut.fetchActivePlan()
            }
        }

        @Test("fetchLog delegates to repository")
        func fetchLogTracked() async throws {
            _ = try await sut.fetchLog(for: .now)
            #expect(spy.fetchLogWasCalled == true)
        }

        @Test("computeSummary uses the real MacroTrackingService")
        func computeSummaryUsesRealService() {
            let plan = NutritionPlan(name: "Plan", targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 60)
            let summary = sut.computeSummary(plan: plan, log: nil)
            #expect(summary.targetCalories == 2000)
            #expect(summary.consumedCalories == 0)
        }

        @Test("saveLog delegates to repository")
        func saveLogTracked() async throws {
            let log = DailyNutritionLog(date: .now)
            try await sut.saveLog(log)
            #expect(spy.saveLogWasCalled == true)
            #expect(spy.lastSavedLog?.id == log.id)
        }

        @Test("addMealLog delegates to repository")
        func addMealLogTracked() async throws {
            let log = DailyNutritionLog(date: .now)
            let mealLog = MealLog(wasFollowed: true)
            try await sut.addMealLog(mealLog, to: log)
            #expect(spy.addMealLogWasCalled == true)
            #expect(spy.lastAddedMealLog?.id == mealLog.id)
        }

        @Test("removeMealLog delegates to repository")
        func removeMealLogTracked() async throws {
            let mealLog = MealLog(wasFollowed: true)
            try await sut.removeMealLog(mealLog)
            #expect(spy.removeMealLogWasCalled == true)
            #expect(spy.lastRemovedMealLog?.id == mealLog.id)
        }
    }
}

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

        let spy: SpyPlanOverviewInteractor

        init() {
            spy = SpyPlanOverviewInteractor()
        }

        @Test("fetchActivePlan is tracked by spy")
        func fetchActivePlanTracked() async throws {
            _ = try await spy.fetchActivePlan()
            #expect(spy.fetchActivePlanWasCalled == true)
        }

        @Test("fetchActivePlan propagates error")
        func fetchActivePlanPropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.loadFailed
            await #expect(throws: NutritionError.self) {
                _ = try await spy.fetchActivePlan()
            }
        }

        @Test("fetchLog is tracked by spy")
        func fetchLogTracked() async throws {
            _ = try await spy.fetchLog(for: .now)
            #expect(spy.fetchLogWasCalled == true)
        }

        @Test("addMealLog tracks last added log")
        func addMealLogTracked() async throws {
            let log = DailyNutritionLog(date: .now)
            let mealLog = MealLog(wasFollowed: true)
            try await spy.addMealLog(mealLog, to: log)
            #expect(spy.addMealLogWasCalled == true)
            #expect(spy.lastAddedMealLog?.id == mealLog.id)
        }

        @Test("removeMealLog tracks last removed log")
        func removeMealLogTracked() async throws {
            let mealLog = MealLog(wasFollowed: true)
            try await spy.removeMealLog(mealLog)
            #expect(spy.removeMealLogWasCalled == true)
            #expect(spy.lastRemovedMealLog?.id == mealLog.id)
        }

        @Test("reset clears all tracking flags")
        func resetClearsFlags() async throws {
            _ = try await spy.fetchActivePlan()
            spy.reset()
            #expect(spy.fetchActivePlanWasCalled == false)
        }
    }
}

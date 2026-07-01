//
//  CreatePlanTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
@testable import Forma

extension CreatePlanTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: CreatePlanInteractor

        // MARK: - Spies

        let spy: SpyNutritionRepository

        // MARK: - Initializers

        init() {
            spy = SpyNutritionRepository()
            sut = CreatePlanInteractor(nutritionRepository: spy)
        }

        @Test("savePlan delegates to repository")
        func savePlanTracked() async throws {
            let plan = NutritionPlan(name: "Plan", targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 60)
            try await sut.savePlan(plan)
            #expect(spy.savePlanWasCalled == true)
            #expect(spy.lastSavedPlan?.id == plan.id)
        }

        @Test("savePlan propagates error")
        func savePlanPropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.saveFailed
            let plan = NutritionPlan(name: "Plan", targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 60)
            await #expect(throws: NutritionError.self) {
                try await sut.savePlan(plan)
            }
        }

        @Test("setActivePlan delegates to repository")
        func setActivePlanTracked() async throws {
            let plan = NutritionPlan(name: "Plan", targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 60)
            try await sut.setActivePlan(plan)
            #expect(spy.setActivePlanWasCalled == true)
        }
    }
}

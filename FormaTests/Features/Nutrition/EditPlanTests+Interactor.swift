//
//  EditPlanTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
@testable import Forma

extension EditPlanTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: EditPlanInteractor

        // MARK: - Spies

        let spy: SpyNutritionRepository

        // MARK: - Initializers

        init() {
            spy = SpyNutritionRepository()
            sut = EditPlanInteractor(nutritionRepository: spy)
        }

        @Test("save delegates to repository")
        func saveTracked() async throws {
            try await sut.save()
            #expect(spy.saveWasCalled == true)
        }

        @Test("save propagates error")
        func savePropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.saveFailed
            await #expect(throws: NutritionError.self) {
                try await sut.save()
            }
        }

        @Test("insertMeal delegates to repository")
        func insertMealTracked() async throws {
            let meal = Meal(name: "Snack", mealType: .snack, order: 0)
            try await sut.insertMeal(meal)
            #expect(spy.insertMealWasCalled == true)
            #expect(spy.lastInsertedMeal?.id == meal.id)
        }

        @Test("deleteMeal delegates to repository")
        func deleteMealTracked() async throws {
            let meal = Meal(name: "Snack", mealType: .snack, order: 0)
            try await sut.deleteMeal(meal)
            #expect(spy.deleteMealWasCalled == true)
            #expect(spy.lastDeletedMeal?.id == meal.id)
        }
    }
}

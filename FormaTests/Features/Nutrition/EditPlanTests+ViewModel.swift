//
//  EditPlanTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
@testable import Forma

extension EditPlanTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: EditNutritionPlanViewModel
        let spy: SpyEditPlanInteractor
        let plan: NutritionPlan

        init() {
            spy = SpyEditPlanInteractor()
            plan = NutritionPlan(name: "Plan", targetCalories: 2000, targetProteinG: 150, targetCarbsG: 200, targetFatG: 60)
            sut = EditNutritionPlanViewModel(plan: plan, interactor: spy)
        }

        @Test("addMeal inserts a meal and updates the sorted list")
        func addMeal() async {
            await sut.addMeal(name: "Snack", type: .snack)
            #expect(spy.insertMealWasCalled == true)
            #expect(sut.meals.count == 1)
            #expect(spy.lastInsertedMeal?.name == "Snack")
        }

        @Test("deleteMeal removes a meal and updates the sorted list")
        func deleteMeal() async throws {
            await sut.addMeal(name: "Snack", type: .snack)
            let meal = try #require(sut.meals.first)
            await sut.deleteMeal(meal)
            #expect(spy.deleteMealWasCalled == true)
            #expect(sut.meals.isEmpty)
        }

        @Test("save() with invalid numeric fields does nothing")
        func saveInvalidInput() async {
            sut.caloriesText = "not a number"
            await sut.save()
            #expect(spy.saveWasCalled == false)
        }

        @Test("save() with valid data persists changes")
        func saveSuccess() async {
            sut.planName = "Updated Plan"
            sut.caloriesText = "2400"
            sut.proteinText = "160"
            sut.carbsText = "230"
            sut.fatText = "75"
            await sut.save()
            #expect(spy.saveWasCalled == true)
            #expect(plan.name == "Updated Plan")
            #expect(plan.targetCalories == 2400)
            #expect(sut.errorMessage == nil)
        }

        @Test("save() sets errorMessage on failure")
        func saveFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.saveFailed
            await sut.save()
            #expect(sut.errorMessage == NutritionError.saveFailed.errorDescription)
        }
    }
}

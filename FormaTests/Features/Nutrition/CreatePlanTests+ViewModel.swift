//
//  CreatePlanTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension CreatePlanTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: CreateNutritionPlanViewModel
        let spy: SpyCreatePlanInteractor

        init() {
            spy = SpyCreatePlanInteractor()
            sut = CreateNutritionPlanViewModel(interactor: spy)
        }

        @Test("init seeds required meals")
        func initialMeals() {
            #expect(sut.requiredMeals.count == 3)
            #expect(sut.optionalMeals.isEmpty)
        }

        @Test("addMeal appends an optional meal")
        func addMeal() {
            sut.addMeal(DraftMeal(name: "Snack", mealType: .snack))
            #expect(sut.optionalMeals.count == 1)
        }

        @Test("removeOptionalMeal removes only optional meals")
        func removeOptionalMeal() {
            sut.addMeal(DraftMeal(name: "Snack", mealType: .snack))
            sut.removeOptionalMeal(at: IndexSet(integer: 0))
            #expect(sut.optionalMeals.isEmpty)
            #expect(sut.requiredMeals.count == 3)
        }

        @Test("save() with invalid numeric fields does nothing")
        func saveInvalidInput() async {
            sut.planName = "My Plan"
            await sut.save()
            #expect(spy.savePlanWasCalled == false)
        }

        @Test("save() with valid data saves and activates the plan")
        func saveSuccess() async {
            fillValidFields(on: sut)
            await sut.save()
            #expect(spy.savePlanWasCalled == true)
            #expect(spy.setActivePlanWasCalled == true)
            #expect(spy.lastSavedPlan?.name == "My Plan")
            #expect(sut.isSaving == false)
            #expect(sut.errorMessage == nil)
        }

        @Test("save() sets errorMessage on failure")
        func saveFailure() async {
            fillValidFields(on: sut)
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.saveFailed
            await sut.save()
            #expect(sut.errorMessage == NutritionError.saveFailed.errorDescription)
            #expect(sut.isSaving == false)
        }
    }
}

// MARK: - Test Helpers

private extension CreatePlanTests.ViewModelTests {
    func fillValidFields(on sut: CreateNutritionPlanViewModel) {
        sut.planName = "My Plan"
        sut.caloriesText = "2200"
        sut.proteinText = "150"
        sut.carbsText = "220"
        sut.fatText = "70"
    }
}

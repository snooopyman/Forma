//
//  MealDetailTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension MealDetailTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: MealDetailViewModel
        let spy: SpyMealDetailInteractor
        let meal: Meal

        init() {
            spy = SpyMealDetailInteractor()
            meal = Meal(name: "Lunch", mealType: .lunch, order: 0)
            let option = MealOption(optionNumber: 1)
            option.meal = meal
            meal.options.append(option)
            sut = MealDetailViewModel(meal: meal, interactor: spy)
        }

        @Test("load() fetches today's log and selects preferred option")
        func loadSelectsPreferredOption() async {
            await sut.load()
            #expect(spy.fetchLogWasCalled == true)
            #expect(sut.selectedOptionIndex == 0)
            #expect(sut.errorMessage == nil)
        }

        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == NutritionError.loadFailed.errorDescription)
        }

        @Test("logSelectedOption() creates a log and adds a meal log")
        func logSelectedOptionSuccess() async {
            await sut.logSelectedOption()
            #expect(spy.saveLogWasCalled == true)
            #expect(spy.addMealLogWasCalled == true)
            #expect(spy.lastAddedMealLog?.selectedOption?.optionNumber == 1)
            #expect(sut.errorMessage == nil)
        }

        @Test("logSelectedOption() sets errorMessage on failure")
        func logSelectedOptionFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.saveFailed
            await sut.logSelectedOption()
            #expect(sut.errorMessage == NutritionError.saveFailed.errorDescription)
        }

        @Test("unlog() removes the existing meal log")
        func unlogRemovesLog() async {
            let log = DailyNutritionLog(date: .now)
            let mealLog = MealLog(wasFollowed: true)
            mealLog.meal = meal
            log.mealLogs.append(mealLog)
            spy.stubbedLog = log
            await sut.load()
            await sut.unlog()
            #expect(spy.removeMealLogWasCalled == true)
        }

        @Test("setPreferredOption() saves and updates meal's preferred option")
        func setPreferredOptionSuccess() async {
            await sut.setPreferredOption()
            #expect(spy.saveWasCalled == true)
            #expect(meal.preferredOptionNumber == 1)
        }

        @Test("addOption() inserts a new option when under the 3-option limit")
        func addOptionSuccess() async {
            await sut.addOption()
            #expect(spy.insertMealOptionWasCalled == true)
            #expect(meal.options.count == 2)
        }

        @Test("addOption() does nothing beyond 3 options")
        func addOptionAtLimit() async {
            meal.options.append(MealOption(optionNumber: 2))
            meal.options.append(MealOption(optionNumber: 3))
            await sut.addOption()
            #expect(spy.insertMealOptionWasCalled == false)
            #expect(meal.options.count == 3)
        }

        @Test("deleteOption() removes the option and resets selection")
        func deleteOptionSuccess() async {
            sut.selectedOptionIndex = 0
            await sut.deleteOption(meal.options[0])
            #expect(spy.deleteMealOptionWasCalled == true)
            #expect(sut.selectedOptionIndex == 0)
        }

        @Test("addFoodItem() inserts an item into the option")
        func addFoodItemSuccess() async {
            let food = FoodItem(name: "Rice", category: "Carbs", mainMacro: .carbs, caloriesPer100g: 130, proteinPer100g: 3, carbsPer100g: 28, fatPer100g: 0)
            let option = meal.options[0]
            await sut.addFoodItem(food, grams: 150, to: option)
            #expect(spy.insertMealOptionItemWasCalled == true)
            #expect(option.items.count == 1)
        }

        @Test("deleteFoodItem() removes the item")
        func deleteFoodItemSuccess() async {
            let item = MealOptionItem(amountGrams: 100)
            await sut.deleteFoodItem(item)
            #expect(spy.deleteMealOptionItemWasCalled == true)
        }
    }
}

//
//  SpyEditPlanInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyEditPlanInteractor: EditPlanInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var saveWasCalled = false
    private(set) var insertMealWasCalled = false
    private(set) var deleteMealWasCalled = false
    private(set) var lastInsertedMeal: Meal?
    private(set) var lastDeletedMeal: Meal?

    // MARK: - Stub Data

    var shouldThrowError = false
    var errorToThrow: Error = NutritionError.saveFailed

    // MARK: - Functions

    func reset() {
        saveWasCalled = false
        insertMealWasCalled = false
        deleteMealWasCalled = false
        lastInsertedMeal = nil
        lastDeletedMeal = nil
    }

    func save() async throws {
        saveWasCalled = true
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
        meal.nutritionPlan?.meals.removeAll { $0.id == meal.id }
    }
}

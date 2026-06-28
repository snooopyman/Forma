//
//  MockEditPlanInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockEditPlanInteractor: EditPlanInteractorProtocol {

    // MARK: - Stub Data

    var shouldThrow = false

    // MARK: - Functions

    func save() async throws {
        if shouldThrow { throw NutritionError.saveFailed }
    }

    func insertMeal(_ meal: Meal) async throws {
        if shouldThrow { throw NutritionError.saveFailed }
    }

    func deleteMeal(_ meal: Meal) async throws {
        if shouldThrow { throw NutritionError.deleteFailed }
    }
}

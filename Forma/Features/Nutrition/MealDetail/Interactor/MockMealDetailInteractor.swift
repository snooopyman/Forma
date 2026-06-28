//
//  MockMealDetailInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockMealDetailInteractor: MealDetailInteractorProtocol {

    // MARK: - Stub Data

    var stubbedLog: DailyNutritionLog?
    var shouldThrowOnLoad = false
    var shouldThrowOnMutate = false

    // MARK: - Functions

    func fetchLog(for date: Date) async throws -> DailyNutritionLog? {
        if shouldThrowOnLoad { throw NutritionError.loadFailed }
        return stubbedLog
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

    func save() async throws {
        if shouldThrowOnMutate { throw NutritionError.saveFailed }
    }

    func insertMealOption(_ option: MealOption) async throws {
        if shouldThrowOnMutate { throw NutritionError.saveFailed }
    }

    func deleteMealOption(_ option: MealOption) async throws {
        if shouldThrowOnMutate { throw NutritionError.deleteFailed }
    }

    func insertMealOptionItem(_ item: MealOptionItem) async throws {
        if shouldThrowOnMutate { throw NutritionError.saveFailed }
    }

    func deleteMealOptionItem(_ item: MealOptionItem) async throws {
        if shouldThrowOnMutate { throw NutritionError.deleteFailed }
    }
}

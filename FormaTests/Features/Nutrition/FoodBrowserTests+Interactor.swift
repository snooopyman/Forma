//
//  FoodBrowserTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
@testable import Forma

extension FoodBrowserTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: FoodBrowserInteractor

        // MARK: - Spies

        let spy: SpyFoodItemRepository

        // MARK: - Initializers

        init() {
            spy = SpyFoodItemRepository()
            sut = FoodBrowserInteractor(foodItemRepository: spy)
        }

        @Test("fetchAllItems delegates to repository")
        func fetchAllItemsTracked() async throws {
            spy.stubbedItems = [FoodItem(name: "Chicken", category: "Protein", mainMacro: .protein, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6)]
            let result = try await sut.fetchAllItems()
            #expect(spy.fetchAllWasCalled == true)
            #expect(result.count == 1)
        }

        @Test("fetchAllItems propagates error")
        func fetchAllItemsPropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.loadFailed
            await #expect(throws: NutritionError.self) {
                _ = try await sut.fetchAllItems()
            }
        }
    }
}

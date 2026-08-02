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
        
        @Test("saveItem delegates to repository")
        func saveItemTracked() async throws {
            let item = FoodItem(name: "Chicken", category: "Protein", mainMacro: .protein, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, isCustom: true)
            try await sut.saveItem(item)
            #expect(spy.saveWasCalled == true)
            #expect(spy.lastSavedItem === item)
        }
        
        @Test("deleteItem deletes when not in use")
        func deleteItemNotInUse() async throws {
            spy.stubbedUsageCount = 0
            let item = FoodItem(name: "Chicken", category: "Protein", mainMacro: .protein, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, isCustom: true)
            try await sut.deleteItem(item)
            #expect(spy.usageCountWasCalled == true)
            #expect(spy.deleteWasCalled == true)
        }
        
        @Test("deleteItem throws inUse and does not delete when used")
        func deleteItemBlockedWhenInUse() async throws {
            spy.stubbedUsageCount = 2
            let item = FoodItem(name: "Chicken", category: "Protein", mainMacro: .protein, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, isCustom: true)
            do {
                try await sut.deleteItem(item)
                Issue.record("Expected deleteItem to throw")
            } catch {
                #expect(error as? NutritionError == NutritionError.inUse(count: 2))
            }
            #expect(spy.deleteWasCalled == false)
        }
    }
}

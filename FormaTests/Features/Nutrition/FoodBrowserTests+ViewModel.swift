//
//  FoodBrowserTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
@testable import Forma

extension FoodBrowserTests {
    
    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {
        
        let sut: FoodBrowserViewModel
        let spy: SpyFoodBrowserInteractor
        
        init() {
            spy = SpyFoodBrowserInteractor()
            sut = FoodBrowserViewModel(interactor: spy)
        }
        
        @Test("load() fetches items and populates allItems")
        func loadSuccess() async {
            spy.stubbedItems = [makeItem(name: "Chicken", category: "Protein")]
            await sut.load()
            #expect(spy.fetchAllItemsWasCalled == true)
            #expect(sut.allItems.count == 1)
            #expect(sut.isLoading == false)
        }
        
        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == NutritionError.loadFailed.errorDescription)
        }
        
        @Test("categories returns unique sorted categories")
        func categories() async {
            spy.stubbedItems = [
                makeItem(name: "Chicken", category: "Protein"),
                makeItem(name: "Rice", category: "Carbs"),
                makeItem(name: "Beef", category: "Protein")
            ]
            await sut.load()
            #expect(sut.categories == ["Carbs", "Protein"])
        }
        
        @Test("filteredItems filters by selected category")
        func filteredItemsByCategory() async {
            spy.stubbedItems = [
                makeItem(name: "Chicken", category: "Protein"),
                makeItem(name: "Rice", category: "Carbs")
            ]
            await sut.load()
            sut.selectedCategory = "Carbs"
            #expect(sut.filteredItems.count == 1)
            #expect(sut.filteredItems.first?.name == "Rice")
        }
        
        @Test("filteredItems filters by search text")
        func filteredItemsBySearch() async {
            spy.stubbedItems = [
                makeItem(name: "Chicken breast", category: "Protein"),
                makeItem(name: "Rice", category: "Carbs")
            ]
            await sut.load()
            sut.searchText = "chick"
            #expect(sut.filteredItems.count == 1)
            #expect(sut.filteredItems.first?.name == "Chicken breast")
        }
        
        @Test("isDuplicateName matches case-insensitively")
        func isDuplicateNameMatches() async {
            spy.stubbedItems = [makeItem(name: "Chicken breast", category: "Protein")]
            await sut.load()
            #expect(sut.isDuplicateName("chicken BREAST", excludingID: nil) == true)
            #expect(sut.isDuplicateName("Rice", excludingID: nil) == false)
        }
        
        @Test("isDuplicateName excludes the item being edited")
        func isDuplicateNameExcludesEditingItem() async {
            let existing = makeItem(name: "Chicken breast", category: "Protein")
            spy.stubbedItems = [existing]
            await sut.load()
            #expect(sut.isDuplicateName("Chicken breast", excludingID: existing.id) == false)
        }
        
        @Test("saveItem persists via interactor and reloads")
        func saveItemSuccess() async {
            let success = await sut.saveItem(makeItem(name: "Oats", category: "Carbs"))
            #expect(spy.saveItemWasCalled == true)
            #expect(spy.fetchAllItemsWasCalled == true)
            #expect(success == true)
        }
        
        @Test("saveItem sets errorMessage on failure")
        func saveItemFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.saveFailed
            let success = await sut.saveItem(makeItem(name: "Oats", category: "Carbs"))
            #expect(success == false)
            #expect(sut.errorMessage == NutritionError.saveFailed.errorDescription)
        }
        
        @Test("deleteItem removes via interactor and reloads")
        func deleteItemSuccess() async {
            let item = makeItem(name: "Oats", category: "Carbs")
            await sut.deleteItem(item)
            #expect(spy.deleteItemWasCalled == true)
            #expect(spy.fetchAllItemsWasCalled == true)
        }
        
        @Test("deleteItem sets errorMessage when item is in use")
        func deleteItemInUse() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.inUse(count: 3)
            let item = makeItem(name: "Oats", category: "Carbs")
            await sut.deleteItem(item)
            #expect(sut.errorMessage == NutritionError.inUse(count: 3).errorDescription)
        }
    }
}

// MARK: - Test Helpers

private extension FoodBrowserTests.ViewModelTests {
    func makeItem(name: String, category: String) -> FoodItem {
        FoodItem(
            name: name,
            category: category,
            mainMacro: .protein,
            caloriesPer100g: 100,
            proteinPer100g: 20,
            carbsPer100g: 0,
            fatPer100g: 2
        )
    }
}

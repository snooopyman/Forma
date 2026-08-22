//
//  FoodItemTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 22/8/26.
//

import Testing
import Foundation
@testable import Forma

@Suite("Food Item Tests")
struct FoodItemTests {

    @Test("displayName resolves a catalogKey against NutritionLocalizable")
    func displayNameResolvesCatalogKey() {
        let item = FoodItem(
            name: "Pechuga de pollo",
            catalogKey: "food_chicken_breast",
            category: "Carne",
            categoryKey: "category_meat",
            mainMacro: .protein,
            caloriesPer100g: 97,
            proteinPer100g: 22,
            carbsPer100g: 0,
            fatPer100g: 1
        )
        #expect(item.displayName == String(localized: String.LocalizationValue("food_chicken_breast"), table: "NutritionLocalizable"))
        #expect(item.displayCategory == String(localized: String.LocalizationValue("category_meat"), table: "NutritionLocalizable"))
    }

    @Test("displayName falls back to the literal name when catalogKey is nil")
    func displayNameFallsBackForCustomItems() {
        let item = FoodItem(
            name: "Grandma's soup",
            category: "Custom",
            mainMacro: .protein,
            caloriesPer100g: 80,
            proteinPer100g: 5,
            carbsPer100g: 8,
            fatPer100g: 2,
            isCustom: true
        )
        #expect(item.displayName == "Grandma's soup")
        #expect(item.displayCategory == "Custom")
    }
}

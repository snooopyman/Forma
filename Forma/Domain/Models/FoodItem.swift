//
//  FoodItem.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class FoodItem {

    var id: UUID
    var name: String
    var catalogKey: String?
    var brand: String
    var category: String
    var categoryKey: String?
    var mainMacro: MacroType
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var fiberPer100g: Double
    var basePortionG: Double
    var isCustom: Bool

    var displayName: String {
        guard let catalogKey else { return name }
        return String(localized: String.LocalizationValue(catalogKey), table: "NutritionLocalizable")
    }

    var displayCategory: String {
        guard let categoryKey else { return category }
        return String(localized: String.LocalizationValue(categoryKey), table: "NutritionLocalizable")
    }

    init(
        id: UUID = UUID(),
        name: String,
        catalogKey: String? = nil,
        brand: String = "",
        category: String,
        categoryKey: String? = nil,
        mainMacro: MacroType,
        caloriesPer100g: Double,
        proteinPer100g: Double,
        carbsPer100g: Double,
        fatPer100g: Double,
        fiberPer100g: Double = 0,
        basePortionG: Double = 100,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.catalogKey = catalogKey
        self.brand = brand
        self.category = category
        self.categoryKey = categoryKey
        self.mainMacro = mainMacro
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
        self.fiberPer100g = fiberPer100g
        self.basePortionG = basePortionG
        self.isCustom = isCustom
    }

    func calories(forGrams grams: Double) -> Double { caloriesPer100g * grams / 100 }
    func protein(forGrams grams: Double) -> Double { proteinPer100g * grams / 100 }
    func carbs(forGrams grams: Double) -> Double { carbsPer100g * grams / 100 }
    func fat(forGrams grams: Double) -> Double { fatPer100g * grams / 100 }
}

enum MacroType: String, Codable, CaseIterable {
    case protein
    case carbs
    case fat

    var localizedName: String {
        switch self {
        case .protein: return L10n.MacroType.protein
        case .carbs:   return L10n.MacroType.carbs
        case .fat:     return L10n.MacroType.fat
        }
    }

    var abbreviation: String {
        switch self {
        case .protein: return L10n.MacroType.Abbreviation.protein
        case .carbs:   return L10n.MacroType.Abbreviation.carbs
        case .fat:     return L10n.MacroType.Abbreviation.fat
        }
    }

    var sortOrder: Int {
        switch self {
        case .protein: return 0
        case .carbs:   return 1
        case .fat:     return 2
        }
    }
}

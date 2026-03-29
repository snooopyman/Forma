//
//  NutritionPlan.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class NutritionPlan {

    var id: UUID
    var name: String
    var isActive: Bool
    var targetCalories: Int
    var targetProteinG: Double
    var targetCarbsG: Double
    var targetFatG: Double
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var meals: [Meal]

    var mesocycle: Mesocycle?

    init(
        id: UUID = UUID(),
        name: String,
        isActive: Bool = false,
        targetCalories: Int,
        targetProteinG: Double,
        targetCarbsG: Double,
        targetFatG: Double,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.targetCalories = targetCalories
        self.targetProteinG = targetProteinG
        self.targetCarbsG = targetCarbsG
        self.targetFatG = targetFatG
        self.createdAt = createdAt
        self.meals = []
    }
}

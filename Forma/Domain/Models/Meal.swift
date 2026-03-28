import Foundation
import SwiftData

@Model
final class Meal {

    var id: UUID
    var name: String
    var mealType: MealType
    var order: Int
    var targetCalories: Int
    var targetProteinG: Double
    var targetCarbsG: Double
    var targetFatG: Double

    @Relationship(deleteRule: .cascade)
    var options: [MealOption]

    var nutritionPlan: NutritionPlan?

    init(
        id: UUID = UUID(),
        name: String,
        mealType: MealType,
        order: Int,
        targetCalories: Int = 0,
        targetProteinG: Double = 0,
        targetCarbsG: Double = 0,
        targetFatG: Double = 0
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.order = order
        self.targetCalories = targetCalories
        self.targetProteinG = targetProteinG
        self.targetCarbsG = targetCarbsG
        self.targetFatG = targetFatG
        self.options = []
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
    case snack
    // Hidden on rest days
    case postWorkout

    var localizedName: String {
        switch self {
        case .breakfast:   return String(localized: "Breakfast")
        case .lunch:       return String(localized: "Lunch")
        case .dinner:      return String(localized: "Dinner")
        case .snack:       return String(localized: "Snack")
        case .postWorkout: return String(localized: "Post-workout")
        }
    }
}

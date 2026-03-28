import Foundation
import SwiftData

@Model
final class MealOption {

    var id: UUID
    var optionNumber: Int
    var notes: String

    @Relationship(deleteRule: .cascade)
    var items: [MealOptionItem]

    var meal: Meal?

    init(
        id: UUID = UUID(),
        optionNumber: Int,
        notes: String = ""
    ) {
        self.id = id
        self.optionNumber = optionNumber
        self.notes = notes
        self.items = []
    }

    var totalCalories: Double {
        items.reduce(0) { $0 + ($1.foodItem?.calories(forGrams: $1.amountGrams) ?? 0) }
    }

    var totalProteinG: Double {
        items.reduce(0) { $0 + ($1.foodItem?.protein(forGrams: $1.amountGrams) ?? 0) }
    }

    var totalCarbsG: Double {
        items.reduce(0) { $0 + ($1.foodItem?.carbs(forGrams: $1.amountGrams) ?? 0) }
    }

    var totalFatG: Double {
        items.reduce(0) { $0 + ($1.foodItem?.fat(forGrams: $1.amountGrams) ?? 0) }
    }
}

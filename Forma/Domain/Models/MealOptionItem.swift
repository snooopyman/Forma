import Foundation
import SwiftData

@Model
final class MealOptionItem {

    var id: UUID
    var amountGrams: Double

    var foodItem: FoodItem?
    var mealOption: MealOption?

    init(
        id: UUID = UUID(),
        amountGrams: Double
    ) {
        self.id = id
        self.amountGrams = amountGrams
    }
}

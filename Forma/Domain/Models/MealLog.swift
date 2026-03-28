import Foundation
import SwiftData

@Model
final class MealLog {

    var id: UUID
    var loggedAt: Date
    var wasFollowed: Bool
    var notes: String

    var meal: Meal?
    var selectedOption: MealOption?
    var dailyLog: DailyNutritionLog?

    init(
        id: UUID = UUID(),
        loggedAt: Date = .now,
        wasFollowed: Bool = true,
        notes: String = ""
    ) {
        self.id = id
        self.loggedAt = loggedAt
        self.wasFollowed = wasFollowed
        self.notes = notes
    }
}

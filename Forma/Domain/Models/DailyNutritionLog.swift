import Foundation
import SwiftData

@Model
final class DailyNutritionLog {

    var id: UUID
    var date: Date
    var adherenceStatus: AdherenceStatus
    var freeNotes: String

    @Relationship(deleteRule: .cascade)
    var mealLogs: [MealLog]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        adherenceStatus: AdherenceStatus = .followed,
        freeNotes: String = ""
    ) {
        self.id = id
        self.date = date
        self.adherenceStatus = adherenceStatus
        self.freeNotes = freeNotes
        self.mealLogs = []
    }
}

enum AdherenceStatus: String, Codable, CaseIterable {
    case followed
    case partial
    case offPlan

    var localizedName: String {
        switch self {
        case .followed: return String(localized: "Followed")
        case .partial:  return String(localized: "Partial")
        case .offPlan:  return String(localized: "Off plan")
        }
    }
}

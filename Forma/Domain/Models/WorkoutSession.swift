import Foundation
import SwiftData

@Model
final class WorkoutSession {

    var id: UUID
    var date: Date
    var sessionType: SessionType
    var startedAt: Date
    var completedAt: Date?
    var notes: String

    var workoutDay: WorkoutDay?
    var mesocycle: Mesocycle?

    @Relationship(deleteRule: .cascade)
    var loggedSets: [LoggedSet]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        sessionType: SessionType = .planned,
        startedAt: Date = .now,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.sessionType = sessionType
        self.startedAt = startedAt
        self.notes = notes
        self.loggedSets = []
    }

    var isCompleted: Bool { completedAt != nil }

    var duration: TimeInterval? {
        guard let completedAt else { return nil }
        return completedAt.timeIntervalSince(startedAt)
    }
}

enum SessionType: String, Codable, CaseIterable {
    case planned
    case freeStyle
    case cardio
    case mobility

    var localizedName: String {
        switch self {
        case .planned:   return String(localized: "Planned")
        case .freeStyle: return String(localized: "Free style")
        case .cardio:    return String(localized: "Cardio")
        case .mobility:  return String(localized: "Mobility")
        }
    }
}

//
//  Mesocycle.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class Mesocycle {

    var id: UUID
    var name: String
    var startDate: Date
    var durationWeeks: Int
    var useFixedDays: Bool
    var isActive: Bool
    var pausedAt: Date?
    var resumedAt: Date?
    var notes: String

    @Relationship(deleteRule: .cascade)
    var workoutDays: [WorkoutDay]

    @Relationship(deleteRule: .cascade)
    var sessions: [WorkoutSession]

    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date = .now,
        durationWeeks: Int = 6,
        useFixedDays: Bool = true,
        isActive: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.durationWeeks = durationWeeks
        self.useFixedDays = useFixedDays
        self.isActive = isActive
        self.notes = notes
        self.workoutDays = []
        self.sessions = []
    }

    var isPaused: Bool { pausedAt != nil && resumedAt == nil }

    var endDate: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: durationWeeks, to: startDate) ?? startDate
    }

    var currentWeek: Int {
        guard !isPaused else { return 0 }
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: .now).weekOfYear ?? 0
        return min(weeks + 1, durationWeeks)
    }
}

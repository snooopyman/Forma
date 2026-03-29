//
//  WorkoutDay.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutDay {

    var id: UUID
    var name: String
    var order: Int
    var weekday: Weekday?
    var isRestDay: Bool
    var restDayActivity: String

    @Relationship(deleteRule: .cascade)
    var plannedExercises: [PlannedExercise]

    var mesocycle: Mesocycle?

    init(
        id: UUID = UUID(),
        name: String,
        order: Int,
        weekday: Weekday? = nil,
        isRestDay: Bool = false,
        restDayActivity: String = ""
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.weekday = weekday
        self.isRestDay = isRestDay
        self.restDayActivity = restDayActivity
        self.plannedExercises = []
    }
}

enum Weekday: Int, Codable, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var localizedName: String {
        switch self {
        case .monday:    return String(localized: "Monday")
        case .tuesday:   return String(localized: "Tuesday")
        case .wednesday: return String(localized: "Wednesday")
        case .thursday:  return String(localized: "Thursday")
        case .friday:    return String(localized: "Friday")
        case .saturday:  return String(localized: "Saturday")
        case .sunday:    return String(localized: "Sunday")
        }
    }

    var shortName: String {
        switch self {
        case .monday:    return String(localized: "Mon")
        case .tuesday:   return String(localized: "Tue")
        case .wednesday: return String(localized: "Wed")
        case .thursday:  return String(localized: "Thu")
        case .friday:    return String(localized: "Fri")
        case .saturday:  return String(localized: "Sat")
        case .sunday:    return String(localized: "Sun")
        }
    }
}

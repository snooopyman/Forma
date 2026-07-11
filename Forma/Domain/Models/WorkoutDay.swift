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
        case .monday:    return L10n.Weekday.monday
        case .tuesday:   return L10n.Weekday.tuesday
        case .wednesday: return L10n.Weekday.wednesday
        case .thursday:  return L10n.Weekday.thursday
        case .friday:    return L10n.Weekday.friday
        case .saturday:  return L10n.Weekday.saturday
        case .sunday:    return L10n.Weekday.sunday
        }
    }
    
    var shortName: String {
        switch self {
        case .monday:    return L10n.Weekday.monShort
        case .tuesday:   return L10n.Weekday.tueShort
        case .wednesday: return L10n.Weekday.wedShort
        case .thursday:  return L10n.Weekday.thuShort
        case .friday:    return L10n.Weekday.friShort
        case .saturday:  return L10n.Weekday.satShort
        case .sunday:    return L10n.Weekday.sunShort
        }
    }
    
    var calendarWeekday: Int {
        switch self {
        case .sunday:    return 1
        case .monday:    return 2
        case .tuesday:   return 3
        case .wednesday: return 4
        case .thursday:  return 5
        case .friday:    return 6
        case .saturday:  return 7
        }
    }
    
    init(calendarWeekday: Int) {
        switch calendarWeekday {
        case 1:  self = .sunday
        case 2:  self = .monday
        case 3:  self = .tuesday
        case 4:  self = .wednesday
        case 5:  self = .thursday
        case 6:  self = .friday
        default: self = .saturday
        }
    }
}

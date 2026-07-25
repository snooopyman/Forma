//
//  NaturalWeek.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import Foundation

enum NaturalWeek {
    static func range(containing date: Date = .now) -> Range<Date> {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? date
        return start..<end
    }
}

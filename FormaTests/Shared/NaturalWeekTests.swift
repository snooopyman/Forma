//
//  NaturalWeekTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 25/7/26.
//

import Testing
import Foundation
@testable import Forma

@Suite("NaturalWeek")
struct NaturalWeekTests {
    
    @Test("range(containing:) always starts on Monday regardless of a Sunday-first locale calendar")
    func alwaysStartsMonday() {
        // Wednesday 2026-07-22
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 22
        let calendar = Calendar(identifier: .gregorian)
        let wednesday = calendar.date(from: components)!
        
        let range = NaturalWeek.range(containing: wednesday)
        
        var isoCalendar = Calendar(identifier: .iso8601)
        isoCalendar.timeZone = .current
        let weekday = isoCalendar.component(.weekday, from: range.lowerBound)
        #expect(weekday == 2) // ISO8601 weekday 2 == Monday
    }
    
    @Test("range(containing:) spans exactly 7 days")
    func spansSevenDays() {
        let range = NaturalWeek.range(containing: .now)
        let days = Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day
        #expect(days == 7)
    }

    @Test("range(containing:) excludes the exact upperBound instant, so it never overlaps the following week")
    func upperBoundIsExclusive() {
        let range = NaturalWeek.range(containing: .now)
        #expect(range.contains(range.upperBound) == false)

        let nextWeekRange = NaturalWeek.range(containing: range.upperBound)
        #expect(nextWeekRange.lowerBound == range.upperBound)
        #expect(nextWeekRange.contains(range.upperBound) == true)
    }
}

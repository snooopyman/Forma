//
//  MeasurementReminderPolicyTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 11/7/26.
//

import Testing
import Foundation
@testable import Forma

@Suite("Measurement Reminder Policy")
struct MeasurementReminderPolicyTests {
    
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }()
    
    // MARK: - shouldRemind
    
    @Test("shouldRemind is true when there is no prior measurement")
    func noPriorMeasurement() {
        let reference = date(year: 2026, month: 7, day: 14) // Tuesday
        #expect(MeasurementReminderPolicy.shouldRemind(
            latestMeasurementDate: nil,
            referenceDate: reference,
            calendar: calendar
        ) == true)
    }
    
    @Test("shouldRemind is false when measured recently and reference is not Monday")
    func recentMeasurementNonMonday() {
        let latest = date(year: 2026, month: 7, day: 12) // Sunday
        let reference = date(year: 2026, month: 7, day: 14) // Tuesday, 2 days later
        #expect(MeasurementReminderPolicy.shouldRemind(
            latestMeasurementDate: latest,
            referenceDate: reference,
            calendar: calendar
        ) == false)
    }
    
    @Test("shouldRemind is true once more than 6 days have passed")
    func staleMeasurement() {
        let latest = date(year: 2026, month: 7, day: 4) // Saturday
        let reference = date(year: 2026, month: 7, day: 12) // Sunday, 8 days later
        #expect(MeasurementReminderPolicy.shouldRemind(
            latestMeasurementDate: latest,
            referenceDate: reference,
            calendar: calendar
        ) == true)
    }
    
    @Test("shouldRemind stays false at exactly 6 days")
    func sixDaysBoundary() {
        let latest = date(year: 2026, month: 7, day: 6) // Monday
        let reference = date(year: 2026, month: 7, day: 12) // Sunday, 6 days later
        #expect(MeasurementReminderPolicy.shouldRemind(
            latestMeasurementDate: latest,
            referenceDate: reference,
            calendar: calendar
        ) == false)
    }
    
    @Test("shouldRemind flips to true at 7 days, independent of the Monday override")
    func sevenDaysBoundary() {
        let latest = date(year: 2026, month: 7, day: 7) // Tuesday
        let reference = date(year: 2026, month: 7, day: 14) // Tuesday, 7 days later — not Monday
        #expect(MeasurementReminderPolicy.shouldRemind(
            latestMeasurementDate: latest,
            referenceDate: reference,
            calendar: calendar
        ) == true)
    }
    
    @Test("shouldRemind is true on Monday even if measured yesterday")
    func mondayOverridesRecentMeasurement() {
        let latest = date(year: 2026, month: 7, day: 12) // Sunday
        let reference = date(year: 2026, month: 7, day: 13) // Monday, 1 day later
        #expect(MeasurementReminderPolicy.shouldRemind(
            latestMeasurementDate: latest,
            referenceDate: reference,
            calendar: calendar
        ) == true)
    }
    
    @Test("shouldRemind ignores the Monday override when treatMondayAsAlwaysDue is false")
    func mondayOverrideCanBeDisabled() {
        let latest = date(year: 2026, month: 7, day: 12) // Sunday
        let reference = date(year: 2026, month: 7, day: 13) // Monday, 1 day later
        #expect(MeasurementReminderPolicy.shouldRemind(
            latestMeasurementDate: latest,
            referenceDate: reference,
            treatMondayAsAlwaysDue: false,
            calendar: calendar
        ) == false)
    }
    
    @Test("shouldRemind compares calendar-day boundaries, not exact timestamps")
    func comparesCalendarDaysNotExactTime() {
        // Measured late in the evening; reference is a scheduled morning time 6 calendar-days later.
        let latest = dateTime(year: 2026, month: 7, day: 6, hour: 23, minute: 30)
        let reference = dateTime(year: 2026, month: 7, day: 12, hour: 9, minute: 0)
        #expect(MeasurementReminderPolicy.shouldRemind(
            latestMeasurementDate: latest,
            referenceDate: reference,
            calendar: calendar
        ) == false)
    }
    
    // MARK: - nextOccurrence
    
    @Test("nextOccurrence resolves the next matching weekday and time strictly after the given date")
    func nextOccurrenceResolvesFutureDate() throws {
        let after = date(year: 2026, month: 7, day: 14) // Tuesday
        let next = try #require(MeasurementReminderPolicy.nextOccurrence(
            weekday: .saturday,
            hour: 9,
            minute: 0,
            after: after,
            calendar: calendar
        ))
        #expect(calendar.component(.weekday, from: next) == Weekday.saturday.calendarWeekday)
        #expect(calendar.component(.hour, from: next) == 9)
        #expect(calendar.component(.minute, from: next) == 0)
        #expect(next > after)
    }
    
    @Test("nextOccurrence skips to next week when the target time today already passed")
    func nextOccurrenceSkipsPassedTimeToday() throws {
        // Saturday at 14:00 — later than the 9:00 target for the same weekday.
        let after = dateTime(year: 2026, month: 7, day: 11, hour: 14, minute: 0)
        let next = try #require(MeasurementReminderPolicy.nextOccurrence(
            weekday: .saturday,
            hour: 9,
            minute: 0,
            after: after,
            calendar: calendar
        ))
        let daysBetween = calendar.dateComponents([.day], from: calendar.startOfDay(for: after), to: calendar.startOfDay(for: next)).day
        #expect(daysBetween == 7)
    }
    
    // MARK: - Helpers
    
    private func date(year: Int, month: Int, day: Int) -> Date {
        dateTime(year: year, month: month, day: day, hour: 0, minute: 0)
    }
    
    private func dateTime(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)!
    }
}

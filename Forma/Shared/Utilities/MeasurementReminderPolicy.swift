//
//  MeasurementReminderPolicy.swift
//  Forma
//
//  Created by Armando Cáceres on 11/7/26.
//

import Foundation

// MARK: - MeasurementReminderPolicy

enum MeasurementReminderPolicy {
    
    // MARK: - Functions
    
    static func shouldRemind(
        latestMeasurementDate: Date?,
        referenceDate: Date,
        treatMondayAsAlwaysDue: Bool = true,
        calendar: Calendar = .current
    ) -> Bool {
        guard let latestMeasurementDate else { return true }
        let startOfLatest = calendar.startOfDay(for: latestMeasurementDate)
        let startOfReference = calendar.startOfDay(for: referenceDate)
        let daysSince = calendar.dateComponents([.day], from: startOfLatest, to: startOfReference).day ?? 0
        
        guard treatMondayAsAlwaysDue else { return daysSince > 6 }
        let isMonday = calendar.component(.weekday, from: referenceDate) == 2
        return isMonday || daysSince > 6
    }
    
    static func nextOccurrence(
        weekday: Weekday,
        hour: Int,
        minute: Int,
        after date: Date,
        calendar: Calendar = .current
    ) -> Date? {
        var components = DateComponents()
        components.weekday = weekday.calendarWeekday
        components.hour = hour
        components.minute = minute
        return calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTime)
    }
}

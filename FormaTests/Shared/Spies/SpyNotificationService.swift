//
//  SpyNotificationService.swift
//  FormaTests
//
//  Created by Armando Cáceres on 11/7/26.
//

import Foundation
import UserNotifications
@testable import Forma

final class SpyNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var requestAuthorizationWasCalled = false
    private(set) var scheduleMeasurementReminderWasCalled = false
    private(set) var cancelMeasurementReminderWasCalled = false
    private(set) var lastScheduledWeekday: Weekday?
    private(set) var lastScheduledHour: Int?
    private(set) var lastScheduledMinute: Int?
    
    // MARK: - Stub Data
    
    var stubbedAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    var stubbedRequestAuthorizationResult = true
    var shouldThrowError = false
    var errorToThrow: Error = SettingsError.saveFailed
    
    // MARK: - Functions
    
    func reset() {
        requestAuthorizationWasCalled = false
        scheduleMeasurementReminderWasCalled = false
        cancelMeasurementReminderWasCalled = false
        lastScheduledWeekday = nil
        lastScheduledHour = nil
        lastScheduledMinute = nil
    }
    
    func authorizationStatus() async -> UNAuthorizationStatus {
        stubbedAuthorizationStatus
    }
    
    func requestAuthorization() async throws -> Bool {
        requestAuthorizationWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedRequestAuthorizationResult
    }
    
    func scheduleMeasurementReminder(weekday: Weekday, hour: Int, minute: Int) async {
        scheduleMeasurementReminderWasCalled = true
        lastScheduledWeekday = weekday
        lastScheduledHour = hour
        lastScheduledMinute = minute
    }
    
    func cancelMeasurementReminder() async {
        cancelMeasurementReminderWasCalled = true
    }
}

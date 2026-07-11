//
//  NotificationService.swift
//  Forma
//
//  Created by Armando Cáceres on 11/7/26.
//

import UserNotifications
import OSLog
import Observation

// MARK: - Deep Link Router

@MainActor
@Observable
final class NotificationDeepLinkRouter {
    static let shared = NotificationDeepLinkRouter()
    private init() {}
    var pendingMeasurementReminder = false
}

// MARK: - Delegate

@MainActor
final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard response.notification.request.identifier == NotificationService.measurementReminderIdentifier else { return }
        NotificationDeepLinkRouter.shared.pendingMeasurementReminder = true
    }
}

// MARK: - Protocol

protocol NotificationServiceProtocol: Sendable {
    func authorizationStatus() async -> UNAuthorizationStatus
    func requestAuthorization() async throws -> Bool
    func scheduleMeasurementReminder(weekday: Weekday, hour: Int, minute: Int) async
    func cancelMeasurementReminder() async
}

// MARK: - Concrete

final class NotificationService: NotificationServiceProtocol, @unchecked Sendable {
    
    // MARK: - Private Properties
    
    static let measurementReminderIdentifier = "measurementReminder"
    private static let measurementReminderCategoryIdentifier = "MEASUREMENT_REMINDER"
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Functions
    
    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }
    
    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleMeasurementReminder(weekday: Weekday, hour: Int, minute: Int) async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.measurementReminderIdentifier])
        
        var components = DateComponents()
        components.weekday = weekday.calendarWeekday
        components.hour = hour
        components.minute = minute
        
        let content = UNMutableNotificationContent()
        content.title = L10n.Notifications.MeasurementReminder.title
        content.body = L10n.Notifications.MeasurementReminder.body
        content.sound = .default
        content.categoryIdentifier = Self.measurementReminderCategoryIdentifier
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.measurementReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
        } catch {
            Logger.notifications.error("Failed to schedule measurement reminder: \(error, privacy: .private)")
        }
    }
    
    func cancelMeasurementReminder() async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.measurementReminderIdentifier])
    }
}

// MARK: - Mock

struct MockNotificationService: NotificationServiceProtocol {
    func authorizationStatus() async -> UNAuthorizationStatus { .authorized }
    func requestAuthorization() async throws -> Bool { true }
    func scheduleMeasurementReminder(weekday: Weekday, hour: Int, minute: Int) async {}
    func cancelMeasurementReminder() async {}
}

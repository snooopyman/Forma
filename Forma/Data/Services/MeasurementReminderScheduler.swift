//
//  MeasurementReminderScheduler.swift
//  Forma
//
//  Created by Armando Cáceres on 11/7/26.
//

import Foundation
import UserNotifications

// MARK: - Protocol

protocol MeasurementReminderSchedulerProtocol: Sendable {
    func reschedule() async
}

// MARK: - Concrete

final class MeasurementReminderScheduler: MeasurementReminderSchedulerProtocol {
    
    // MARK: - Private Properties
    
    private let userProfileRepository: UserProfileRepositoryProtocol
    private let measurementRepository: BodyMeasurementRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    
    // MARK: - Initializers
    
    init(
        userProfileRepository: UserProfileRepositoryProtocol,
        measurementRepository: BodyMeasurementRepositoryProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.userProfileRepository = userProfileRepository
        self.measurementRepository = measurementRepository
        self.notificationService = notificationService
    }
    
    // MARK: - Functions
    
    func reschedule() async {
        guard
            let profile = try? await userProfileRepository.fetch(),
            profile.notificationsEnabled,
            await notificationService.authorizationStatus() == .authorized
        else {
            await notificationService.cancelMeasurementReminder()
            return
        }
        
        let weekday = profile.reminderWeekday ?? .saturday
        guard
            let nextOccurrence = MeasurementReminderPolicy.nextOccurrence(
                weekday: weekday,
                hour: profile.reminderHour,
                minute: profile.reminderMinute,
                after: .now
            )
        else {
            await notificationService.cancelMeasurementReminder()
            return
        }
        
        let latest = try? await measurementRepository.fetchLatest()
        if MeasurementReminderPolicy.shouldRemind(
            latestMeasurementDate: latest?.date,
            referenceDate: nextOccurrence,
            treatMondayAsAlwaysDue: false
        ) {
            await notificationService.scheduleMeasurementReminder(
                weekday: weekday,
                hour: profile.reminderHour,
                minute: profile.reminderMinute
            )
        } else {
            await notificationService.cancelMeasurementReminder()
        }
    }
}

// MARK: - Mock

struct MockMeasurementReminderScheduler: MeasurementReminderSchedulerProtocol {
    func reschedule() async {}
}

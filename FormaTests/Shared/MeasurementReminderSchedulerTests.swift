//
//  MeasurementReminderSchedulerTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 11/7/26.
//

import Testing
import Foundation
import UserNotifications
@testable import Forma

@Suite("Measurement Reminder Scheduler")
@MainActor
struct MeasurementReminderSchedulerTests {
    
    // MARK: - Subject Under Test
    
    let sut: MeasurementReminderScheduler
    
    // MARK: - Spies
    
    let spyProfileRepository: SpyUserProfileRepository
    let spyMeasurementRepository: SpyBodyMeasurementRepository
    let spyNotificationService: SpyNotificationService
    
    // MARK: - Initializers
    
    init() {
        spyProfileRepository = SpyUserProfileRepository()
        spyMeasurementRepository = SpyBodyMeasurementRepository()
        spyNotificationService = SpyNotificationService()
        sut = MeasurementReminderScheduler(
            userProfileRepository: spyProfileRepository,
            measurementRepository: spyMeasurementRepository,
            notificationService: spyNotificationService
        )
    }
    
    // MARK: - Tests
    
    @Test("reschedule cancels when there is no profile")
    func noProfileCancels() async {
        spyProfileRepository.stubbedProfile = nil
        
        await sut.reschedule()
        
        #expect(spyNotificationService.cancelMeasurementReminderWasCalled == true)
        #expect(spyNotificationService.scheduleMeasurementReminderWasCalled == false)
    }
    
    @Test("reschedule cancels when notifications are disabled in the profile")
    func notificationsDisabledCancels() async {
        let profile = makeProfile(notificationsEnabled: false)
        spyProfileRepository.stubbedProfile = profile
        
        await sut.reschedule()
        
        #expect(spyNotificationService.cancelMeasurementReminderWasCalled == true)
        #expect(spyNotificationService.scheduleMeasurementReminderWasCalled == false)
    }
    
    @Test("reschedule cancels when system authorization was revoked")
    func revokedAuthorizationCancels() async {
        let profile = makeProfile(notificationsEnabled: true)
        spyProfileRepository.stubbedProfile = profile
        spyNotificationService.stubbedAuthorizationStatus = .denied
        
        await sut.reschedule()
        
        #expect(spyNotificationService.cancelMeasurementReminderWasCalled == true)
        #expect(spyNotificationService.scheduleMeasurementReminderWasCalled == false)
    }
    
    @Test("reschedule cancels when the user already measured this week")
    func recentMeasurementCancels() async throws {
        let profile = makeProfile(notificationsEnabled: true, reminderWeekday: .saturday, reminderHour: 9, reminderMinute: 0)
        spyProfileRepository.stubbedProfile = profile
        spyNotificationService.stubbedAuthorizationStatus = .authorized
        
        // Derived from the same policy the scheduler uses internally, rather than `.now`, so the
        // test doesn't flake depending on which weekday it happens to run on (`nextOccurrence` can
        // land 0-7 days out depending on the current date relative to the reminder's weekday/time).
        let nextOccurrence = try #require(MeasurementReminderPolicy.nextOccurrence(
            weekday: .saturday, hour: 9, minute: 0, after: .now
        ))
        let measuredYesterday = try #require(Calendar.current.date(byAdding: .day, value: -1, to: nextOccurrence))
        spyMeasurementRepository.stubbedLatest = BodyMeasurement(
            date: measuredYesterday,
            weightKg: 70,
            heightCm: 175,
            biologicalSex: .male
        )
        
        await sut.reschedule()
        
        #expect(spyNotificationService.cancelMeasurementReminderWasCalled == true)
        #expect(spyNotificationService.scheduleMeasurementReminderWasCalled == false)
    }
    
    @Test("reschedule cancels when reminder weekday is Monday and the user already measured today")
    func mondayReminderDoesNotOverrideRecentMeasurement() async throws {
        let profile = makeProfile(notificationsEnabled: true, reminderWeekday: .monday, reminderHour: 9, reminderMinute: 0)
        spyProfileRepository.stubbedProfile = profile
        spyNotificationService.stubbedAuthorizationStatus = .authorized
        
        let nextOccurrence = try #require(MeasurementReminderPolicy.nextOccurrence(
            weekday: .monday, hour: 9, minute: 0, after: .now
        ))
        // Measured earlier the same calendar day as the next Monday occurrence — should not
        // re-schedule just because that day happens to be a Monday.
        spyMeasurementRepository.stubbedLatest = BodyMeasurement(
            date: nextOccurrence,
            weightKg: 70,
            heightCm: 175,
            biologicalSex: .male
        )
        
        await sut.reschedule()
        
        #expect(spyNotificationService.cancelMeasurementReminderWasCalled == true)
        #expect(spyNotificationService.scheduleMeasurementReminderWasCalled == false)
    }
    
    @Test("reschedule schedules with the profile's weekday/hour/minute when a reminder is due")
    func dueReminderSchedules() async {
        let profile = makeProfile(
            notificationsEnabled: true,
            reminderWeekday: .saturday,
            reminderHour: 9,
            reminderMinute: 30
        )
        spyProfileRepository.stubbedProfile = profile
        spyNotificationService.stubbedAuthorizationStatus = .authorized
        spyMeasurementRepository.stubbedLatest = nil // never measured -> always due
        
        await sut.reschedule()
        
        #expect(spyNotificationService.scheduleMeasurementReminderWasCalled == true)
        #expect(spyNotificationService.cancelMeasurementReminderWasCalled == false)
        #expect(spyNotificationService.lastScheduledWeekday == .saturday)
        #expect(spyNotificationService.lastScheduledHour == 9)
        #expect(spyNotificationService.lastScheduledMinute == 30)
    }
    
    // MARK: - Helpers
    
    private func makeProfile(
        notificationsEnabled: Bool,
        reminderWeekday: Weekday = .saturday,
        reminderHour: Int = 9,
        reminderMinute: Int = 0
    ) -> UserProfile {
        UserProfile(
            name: "Ana",
            birthDate: .now,
            heightCm: 165,
            biologicalSex: .female,
            notificationsEnabled: notificationsEnabled,
            reminderWeekday: reminderWeekday,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute
        )
    }
}

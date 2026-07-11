//
//  SettingsInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation
import UserNotifications

final class SettingsInteractor: SettingsInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let userProfileRepository: UserProfileRepositoryProtocol
    private let healthKitService: HealthKitServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let measurementReminderScheduler: MeasurementReminderSchedulerProtocol
    
    // MARK: - Initializers
    
    init(
        userProfileRepository: UserProfileRepositoryProtocol,
        healthKitService: HealthKitServiceProtocol,
        notificationService: NotificationServiceProtocol,
        measurementReminderScheduler: MeasurementReminderSchedulerProtocol
    ) {
        self.userProfileRepository = userProfileRepository
        self.healthKitService = healthKitService
        self.notificationService = notificationService
        self.measurementReminderScheduler = measurementReminderScheduler
    }
    
    // MARK: - Computed Properties
    
    var isHealthKitAvailable: Bool { healthKitService.isAvailable }
    var isHealthKitAuthorized: Bool { healthKitService.isAuthorized }
    
    // MARK: - Functions
    
    func loadProfile() async throws -> UserProfile? {
        try await userProfileRepository.fetch()
    }
    
    func requestHealthKitAccess() async throws {
        try await healthKitService.requestAuthorization()
    }
    
    func notificationAuthorizationStatus() async -> UNAuthorizationStatus {
        await notificationService.authorizationStatus()
    }
    
    func requestNotificationAccess() async throws -> Bool {
        try await notificationService.requestAuthorization()
    }
    
    func saveNotificationPreference(_ profile: UserProfile) async throws {
        try await userProfileRepository.save(profile)
        await measurementReminderScheduler.reschedule()
    }
}

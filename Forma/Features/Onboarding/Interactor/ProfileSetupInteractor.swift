//
//  ProfileSetupInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class ProfileSetupInteractor: ProfileSetupInteractorProtocol {
    
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
    
    // MARK: - Functions
    
    func fetchProfile() async throws -> UserProfile? {
        try await userProfileRepository.fetch()
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        try await userProfileRepository.save(profile)
    }
    
    func requestHealthKitAccess() async throws {
        try await healthKitService.requestAuthorization()
    }
    
    func requestNotificationAccess() async throws -> Bool {
        try await notificationService.requestAuthorization()
    }
    
    func rescheduleMeasurementReminder() async {
        await measurementReminderScheduler.reschedule()
    }
}

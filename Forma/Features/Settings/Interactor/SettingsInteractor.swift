//
//  SettingsInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class SettingsInteractor: SettingsInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let userProfileRepository: UserProfileRepositoryProtocol
    private let healthKitService: HealthKitServiceProtocol
    
    // MARK: - Initializers
    
    init(
        userProfileRepository: UserProfileRepositoryProtocol,
        healthKitService: HealthKitServiceProtocol
    ) {
        self.userProfileRepository = userProfileRepository
        self.healthKitService = healthKitService
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
}

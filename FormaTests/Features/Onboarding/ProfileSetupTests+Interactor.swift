//
//  ProfileSetupTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension ProfileSetupTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: ProfileSetupInteractor

        // MARK: - Spies

        let spyRepository: SpyUserProfileRepository
        let spyHealthKitService: SpyHealthKitService

        // MARK: - Initializers

        init() {
            spyRepository = SpyUserProfileRepository()
            spyHealthKitService = SpyHealthKitService()
            sut = ProfileSetupInteractor(userProfileRepository: spyRepository, healthKitService: spyHealthKitService)
        }

        @Test("fetchProfile delegates to repository")
        func fetchProfileTracked() async throws {
            _ = try await sut.fetchProfile()
            #expect(spyRepository.fetchWasCalled == true)
        }

        @Test("saveProfile delegates to repository")
        func saveProfileTracked() async throws {
            let profile = UserProfile(name: "Ana", birthDate: .now, heightCm: 165, biologicalSex: .female)
            try await sut.saveProfile(profile)
            #expect(spyRepository.saveWasCalled == true)
            #expect(spyRepository.lastSavedProfile?.id == profile.id)
        }

        @Test("saveProfile propagates error")
        func saveProfilePropagatesError() async {
            spyRepository.shouldThrowError = true
            spyRepository.errorToThrow = SettingsError.saveFailed
            let profile = UserProfile(name: "Ana", birthDate: .now, heightCm: 165, biologicalSex: .female)
            await #expect(throws: SettingsError.self) {
                try await sut.saveProfile(profile)
            }
        }

        @Test("requestHealthKitAccess delegates to HealthKit service")
        func requestHealthKitAccessTracked() async throws {
            try await sut.requestHealthKitAccess()
            #expect(spyHealthKitService.requestAuthorizationWasCalled == true)
        }
    }
}

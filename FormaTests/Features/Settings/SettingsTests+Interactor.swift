//
//  SettingsTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension SettingsTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: SettingsInteractor

        // MARK: - Spies

        let spyRepository: SpyUserProfileRepository
        let spyHealthKitService: SpyHealthKitService

        // MARK: - Initializers

        init() {
            spyRepository = SpyUserProfileRepository()
            spyHealthKitService = SpyHealthKitService()
            sut = SettingsInteractor(userProfileRepository: spyRepository, healthKitService: spyHealthKitService)
        }

        @Test("loadProfile delegates to repository")
        func loadProfileTracked() async throws {
            _ = try await sut.loadProfile()
            #expect(spyRepository.fetchWasCalled == true)
        }

        @Test("loadProfile propagates error")
        func loadProfilePropagatesError() async {
            spyRepository.shouldThrowError = true
            spyRepository.errorToThrow = SettingsError.loadFailed
            await #expect(throws: SettingsError.self) {
                _ = try await sut.loadProfile()
            }
        }

        @Test("requestHealthKitAccess delegates to HealthKit service")
        func requestHealthKitAccessTracked() async throws {
            try await sut.requestHealthKitAccess()
            #expect(spyHealthKitService.requestAuthorizationWasCalled == true)
        }

        @Test("isHealthKitAvailable/Authorized reflect the HealthKit service")
        func healthKitFlags() {
            spyHealthKitService.isAvailable = true
            spyHealthKitService.isAuthorized = true
            #expect(sut.isHealthKitAvailable == true)
            #expect(sut.isHealthKitAuthorized == true)
        }
    }
}

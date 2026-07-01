//
//  EditProfileTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension EditProfileTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: EditProfileInteractor

        // MARK: - Spies

        let spy: SpyUserProfileRepository

        // MARK: - Initializers

        init() {
            spy = SpyUserProfileRepository()
            sut = EditProfileInteractor(userProfileRepository: spy)
        }

        @Test("saveProfile delegates to repository")
        func saveProfileTracked() async throws {
            let profile = UserProfile(name: "Ana", birthDate: .now, heightCm: 165, biologicalSex: .female)
            try await sut.saveProfile(profile)
            #expect(spy.saveWasCalled == true)
            #expect(spy.lastSavedProfile?.id == profile.id)
        }

        @Test("saveProfile propagates error")
        func saveProfilePropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = SettingsError.saveFailed
            let profile = UserProfile(name: "Ana", birthDate: .now, heightCm: 165, biologicalSex: .female)
            await #expect(throws: SettingsError.self) {
                try await sut.saveProfile(profile)
            }
        }
    }
}

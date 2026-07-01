//
//  MockProfileSetupInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockProfileSetupInteractor: ProfileSetupInteractorProtocol {

    // MARK: - Stub Data

    nonisolated(unsafe) var stubbedProfile: UserProfile?
    nonisolated(unsafe) var shouldThrowOnSave = false

    // MARK: - Functions

    func fetchProfile() async throws -> UserProfile? {
        stubbedProfile
    }

    func saveProfile(_ profile: UserProfile) async throws {
        if shouldThrowOnSave { throw SettingsError.saveFailed }
    }

    func requestHealthKitAccess() async throws { }
}

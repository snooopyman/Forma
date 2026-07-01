//
//  SpyUserProfileRepository.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyUserProfileRepository: UserProfileRepositoryProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var fetchWasCalled = false
    private(set) var saveWasCalled = false
    private(set) var lastSavedProfile: UserProfile?

    // MARK: - Stub Data

    var stubbedProfile: UserProfile?
    var shouldThrowError = false
    var errorToThrow: Error = SettingsError.loadFailed

    // MARK: - Functions

    func reset() {
        fetchWasCalled = false
        saveWasCalled = false
        lastSavedProfile = nil
    }

    func fetch() async throws -> UserProfile? {
        fetchWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedProfile
    }

    func save(_ profile: UserProfile) async throws {
        saveWasCalled = true
        lastSavedProfile = profile
        if shouldThrowError { throw errorToThrow }
    }
}

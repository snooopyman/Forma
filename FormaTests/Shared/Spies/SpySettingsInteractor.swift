//
//  SpySettingsInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpySettingsInteractor: SettingsInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var loadProfileWasCalled = false
    private(set) var requestHealthKitAccessWasCalled = false

    // MARK: - Stub Data

    var stubbedProfile: UserProfile?
    var isHealthKitAvailable = true
    var isHealthKitAuthorized = false
    var shouldThrowError = false
    var errorToThrow: Error = SettingsError.loadFailed

    // MARK: - Functions

    func reset() {
        loadProfileWasCalled = false
        requestHealthKitAccessWasCalled = false
    }

    func loadProfile() async throws -> UserProfile? {
        loadProfileWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedProfile
    }

    func requestHealthKitAccess() async throws {
        requestHealthKitAccessWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
}

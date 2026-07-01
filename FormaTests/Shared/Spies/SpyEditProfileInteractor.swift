//
//  SpyEditProfileInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyEditProfileInteractor: EditProfileInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var saveProfileWasCalled = false
    private(set) var lastSavedProfile: UserProfile?

    // MARK: - Stub Data

    var shouldThrowError = false
    var errorToThrow: Error = SettingsError.saveFailed

    // MARK: - Functions

    func reset() {
        saveProfileWasCalled = false
        lastSavedProfile = nil
    }

    func saveProfile(_ profile: UserProfile) async throws {
        saveProfileWasCalled = true
        lastSavedProfile = profile
        if shouldThrowError { throw errorToThrow }
    }
}

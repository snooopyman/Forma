//
//  SpySettingsInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
import UserNotifications
@testable import Forma

final class SpySettingsInteractor: SettingsInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var loadProfileWasCalled = false
    private(set) var requestHealthKitAccessWasCalled = false
    private(set) var requestNotificationAccessWasCalled = false
    private(set) var saveNotificationPreferenceWasCalled = false
    private(set) var lastSavedNotificationPreference: UserProfile?
    
    // MARK: - Stub Data
    
    var stubbedProfile: UserProfile?
    var isHealthKitAvailable = true
    var isHealthKitAuthorized = false
    var stubbedNotificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    var stubbedRequestNotificationAccessResult = true
    var shouldThrowError = false
    var errorToThrow: Error = SettingsError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        loadProfileWasCalled = false
        requestHealthKitAccessWasCalled = false
        requestNotificationAccessWasCalled = false
        saveNotificationPreferenceWasCalled = false
        lastSavedNotificationPreference = nil
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
    
    func notificationAuthorizationStatus() async -> UNAuthorizationStatus {
        stubbedNotificationAuthorizationStatus
    }
    
    func requestNotificationAccess() async throws -> Bool {
        requestNotificationAccessWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedRequestNotificationAccessResult
    }
    
    func saveNotificationPreference(_ profile: UserProfile) async throws {
        saveNotificationPreferenceWasCalled = true
        lastSavedNotificationPreference = profile
        if shouldThrowError { throw errorToThrow }
    }
}

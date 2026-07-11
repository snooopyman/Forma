//
//  SpyProfileSetupInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyProfileSetupInteractor: ProfileSetupInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var fetchProfileWasCalled = false
    private(set) var saveProfileWasCalled = false
    private(set) var requestHealthKitAccessWasCalled = false
    private(set) var requestNotificationAccessWasCalled = false
    private(set) var rescheduleMeasurementReminderWasCalled = false
    private(set) var lastSavedProfile: UserProfile?
    
    // MARK: - Stub Data
    
    var stubbedProfile: UserProfile?
    var stubbedRequestNotificationAccessResult = true
    var shouldThrowError = false
    var errorToThrow: Error = SettingsError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchProfileWasCalled = false
        saveProfileWasCalled = false
        requestHealthKitAccessWasCalled = false
        requestNotificationAccessWasCalled = false
        rescheduleMeasurementReminderWasCalled = false
        lastSavedProfile = nil
    }
    
    func fetchProfile() async throws -> UserProfile? {
        fetchProfileWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedProfile
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        saveProfileWasCalled = true
        lastSavedProfile = profile
        if shouldThrowError { throw errorToThrow }
    }
    
    func requestHealthKitAccess() async throws {
        requestHealthKitAccessWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
    
    func requestNotificationAccess() async throws -> Bool {
        requestNotificationAccessWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedRequestNotificationAccessResult
    }
    
    func rescheduleMeasurementReminder() async {
        rescheduleMeasurementReminderWasCalled = true
    }
}

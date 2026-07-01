//
//  MockSettingsInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockSettingsInteractor: SettingsInteractorProtocol {
    
    // MARK: - Stub Data
    
    nonisolated(unsafe) var stubbedProfile: UserProfile?
    nonisolated(unsafe) var shouldThrowOnLoad = false
    nonisolated(unsafe) var shouldThrowOnHealthKit = false
    
    // MARK: - Functions
    
    func loadProfile() async throws -> UserProfile? {
        if shouldThrowOnLoad { throw SettingsError.loadFailed }
        return stubbedProfile
    }
    
    func requestHealthKitAccess() async throws {
        if shouldThrowOnHealthKit { throw SettingsError.loadFailed }
    }
}

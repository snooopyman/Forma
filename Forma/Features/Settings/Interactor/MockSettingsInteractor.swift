//
//  MockSettingsInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockSettingsInteractor: SettingsInteractorProtocol {
    
    // MARK: - Stub Data
    
    var stubbedProfile: UserProfile?
    var shouldThrowOnLoad = false
    var shouldThrowOnHealthKit = false
    
    // MARK: - Functions
    
    func loadProfile() async throws -> UserProfile? {
        if shouldThrowOnLoad { throw SettingsError.loadFailed }
        return stubbedProfile
    }
    
    func requestHealthKitAccess() async throws {
        if shouldThrowOnHealthKit { throw SettingsError.loadFailed }
    }
}

//
//  MockEditProfileInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockEditProfileInteractor: EditProfileInteractorProtocol {
    
    // MARK: - Stub Data
    
    nonisolated(unsafe) var shouldThrow = false
    
    // MARK: - Functions
    
    func saveProfile(_ profile: UserProfile) async throws {
        if shouldThrow { throw SettingsError.saveFailed }
    }
}

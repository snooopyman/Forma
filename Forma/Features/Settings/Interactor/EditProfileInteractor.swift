//
//  EditProfileInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class EditProfileInteractor: EditProfileInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let userProfileRepository: UserProfileRepositoryProtocol
    
    // MARK: - Initializers
    
    init(userProfileRepository: UserProfileRepositoryProtocol) {
        self.userProfileRepository = userProfileRepository
    }
    
    // MARK: - Functions
    
    func saveProfile(_ profile: UserProfile) async throws {
        try await userProfileRepository.save(profile)
    }
}

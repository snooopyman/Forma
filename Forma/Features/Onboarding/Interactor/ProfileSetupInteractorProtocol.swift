//
//  ProfileSetupInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol ProfileSetupInteractorProtocol: Sendable {
    func fetchProfile() async throws -> UserProfile?
    func saveProfile(_ profile: UserProfile) async throws
    func requestHealthKitAccess() async throws
}

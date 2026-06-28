//
//  EditProfileInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol EditProfileInteractorProtocol: Sendable {
    func saveProfile(_ profile: UserProfile) async throws
}

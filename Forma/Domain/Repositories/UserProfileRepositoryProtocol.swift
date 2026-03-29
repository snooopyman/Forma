//
//  UserProfileRepositoryProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation

protocol UserProfileRepositoryProtocol: Sendable {
    func fetch() async throws -> UserProfile?
    func save(_ profile: UserProfile) async throws
}

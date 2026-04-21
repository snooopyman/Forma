//
//  UserProfileRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftData

final class UserProfileRepository: UserProfileRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetch() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        let results: [UserProfile] = try modelContext.fetch(descriptor)
        return results.first
    }

    func save(_ profile: UserProfile) async throws {
        modelContext.insert(profile)
        try modelContext.save()
    }
}

// MARK: - Mock

struct MockUserProfileRepository: UserProfileRepositoryProtocol {
    func fetch() async throws -> UserProfile? { nil }
    func save(_ profile: UserProfile) async throws {}
}

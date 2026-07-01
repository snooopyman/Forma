//
//  UserProfileRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftData

final class UserProfileRepository: UserProfileRepositoryProtocol {
    
    nonisolated(unsafe) private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetch() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        do {
            let results: [UserProfile] = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            throw SettingsError.loadFailed
        }
    }
    
    func save(_ profile: UserProfile) async throws {
        modelContext.insert(profile)
        do {
            try modelContext.save()
        }
        catch {
            throw SettingsError.saveFailed
        }
    }
}

// MARK: - Mock

struct MockUserProfileRepository: UserProfileRepositoryProtocol {
    func fetch() async throws -> UserProfile? { nil }
    func save(_ profile: UserProfile) async throws {}
}

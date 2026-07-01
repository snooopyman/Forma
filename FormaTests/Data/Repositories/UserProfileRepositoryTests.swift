//
//  UserProfileRepositoryTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
import SwiftData
@testable import Forma

@Suite("User Profile Repository Tests")
@MainActor
struct UserProfileRepositoryTests {

    // MARK: - Properties

    let sut: UserProfileRepository
    let modelContainer: ModelContainer

    // MARK: - Initializers

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: UserProfile.self,
            configurations: config
        )
        sut = UserProfileRepository(modelContext: modelContainer.mainContext)
    }

    // MARK: - fetch

    @Test("fetch returns nil when no profile exists")
    func fetchNilWhenEmpty() async throws {
        let result = try await sut.fetch()
        #expect(result == nil)
    }

    // MARK: - save / fetch round-trip

    @Test("save and fetch round-trip preserves profile fields")
    func saveAndFetch() async throws {
        let profile = UserProfile(
            name: "Ana",
            birthDate: Date(timeIntervalSince1970: 0),
            heightCm: 172,
            biologicalSex: .female
        )
        try await sut.save(profile)
        let result = try await sut.fetch()
        #expect(result?.name == "Ana")
        #expect(result?.heightCm == 172)
        #expect(result?.biologicalSex == .female)
    }

    @Test("fetch returns the only saved profile")
    func fetchReturnsSingleProfile() async throws {
        let profile = UserProfile(
            name: "Carlos",
            birthDate: Date(timeIntervalSince1970: 0),
            heightCm: 180,
            biologicalSex: .male
        )
        try await sut.save(profile)
        let result = try await sut.fetch()
        #expect(result?.id == profile.id)
    }
}

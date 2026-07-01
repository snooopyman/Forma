//
//  ProgressPhotoRepositoryTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
import SwiftData
@testable import Forma

@Suite("Progress Photo Repository Tests")
@MainActor
struct ProgressPhotoRepositoryTests {

    // MARK: - Properties

    let sut: ProgressPhotoRepository
    let modelContainer: ModelContainer

    // MARK: - Initializers

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: ProgressPhoto.self,
            configurations: config
        )
        sut = ProgressPhotoRepository(modelContext: modelContainer.mainContext)
    }

    // MARK: - fetchAll

    @Test("fetchAll returns empty when no photos")
    func fetchAllEmpty() async throws {
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }

    @Test("fetchAll returns all saved photos sorted by date descending")
    func fetchAllSortedDescending() async throws {
        let older = Self.makePhoto(date: Date(timeIntervalSinceNow: -7 * 86400), angle: .front)
        let newer = Self.makePhoto(date: .now, angle: .back)
        try await sut.save(older)
        try await sut.save(newer)
        let result = try await sut.fetchAll()
        #expect(result.count == 2)
        #expect(result.first?.angle == .back)
    }

    // MARK: - save / delete round-trip

    @Test("save and fetchAll round-trip preserves angle and notes")
    func saveAndFetch() async throws {
        let photo = Self.makePhoto(angle: .sideLeft, notes: "Week 4")
        try await sut.save(photo)
        let result = try await sut.fetchAll()
        #expect(result.count == 1)
        #expect(result.first?.angle == .sideLeft)
        #expect(result.first?.notes == "Week 4")
    }

    @Test("delete removes photo from store")
    func deletePhoto() async throws {
        let photo = Self.makePhoto(angle: .front)
        try await sut.save(photo)
        try await sut.delete(photo)
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }
}

// MARK: - Test Data

private extension ProgressPhotoRepositoryTests {
    static func makePhoto(
        date: Date = .now,
        angle: PhotoAngle,
        notes: String = ""
    ) -> ProgressPhoto {
        ProgressPhoto(date: date, angle: angle, imageData: Data([0x01, 0x02]), notes: notes)
    }
}

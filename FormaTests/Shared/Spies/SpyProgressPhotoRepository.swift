//
//  SpyProgressPhotoRepository.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyProgressPhotoRepository: ProgressPhotoRepositoryProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var fetchAllWasCalled = false
    private(set) var saveWasCalled = false
    private(set) var deleteWasCalled = false
    private(set) var lastSavedPhoto: ProgressPhoto?
    private(set) var lastDeletedPhoto: ProgressPhoto?

    // MARK: - Stub Data

    var stubbedPhotos: [ProgressPhoto] = []
    var shouldThrowError = false
    var errorToThrow: Error = ProgressError.loadFailed

    // MARK: - Functions

    func reset() {
        fetchAllWasCalled = false
        saveWasCalled = false
        deleteWasCalled = false
        lastSavedPhoto = nil
        lastDeletedPhoto = nil
    }

    func fetchAll() async throws -> [ProgressPhoto] {
        fetchAllWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedPhotos
    }

    func save(_ photo: ProgressPhoto) async throws {
        saveWasCalled = true
        lastSavedPhoto = photo
        if shouldThrowError { throw errorToThrow }
    }

    func delete(_ photo: ProgressPhoto) async throws {
        deleteWasCalled = true
        lastDeletedPhoto = photo
        if shouldThrowError { throw errorToThrow }
    }
}

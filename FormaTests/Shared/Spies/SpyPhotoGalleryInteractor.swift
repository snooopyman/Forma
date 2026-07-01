//
//  SpyPhotoGalleryInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyPhotoGalleryInteractor: PhotoGalleryInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var fetchPhotosWasCalled = false
    private(set) var deletePhotoWasCalled = false
    private(set) var lastDeletedPhoto: ProgressPhoto?

    // MARK: - Stub Data

    var stubbedPhotos: [ProgressPhoto] = []
    var shouldThrowError = false
    var errorToThrow: Error = ProgressError.loadFailed

    // MARK: - Functions

    func reset() {
        fetchPhotosWasCalled = false
        deletePhotoWasCalled = false
        lastDeletedPhoto = nil
    }

    func fetchPhotos() async throws -> [ProgressPhoto] {
        fetchPhotosWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedPhotos
    }

    func deletePhoto(_ photo: ProgressPhoto) async throws {
        deletePhotoWasCalled = true
        lastDeletedPhoto = photo
        if shouldThrowError { throw errorToThrow }
    }
}

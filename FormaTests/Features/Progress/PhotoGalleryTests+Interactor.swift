//
//  PhotoGalleryTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension PhotoGalleryTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: PhotoGalleryInteractor

        // MARK: - Spies

        let spy: SpyProgressPhotoRepository

        // MARK: - Initializers

        init() {
            spy = SpyProgressPhotoRepository()
            sut = PhotoGalleryInteractor(repository: spy)
        }

        @Test("fetchPhotos delegates to repository")
        func fetchPhotosTracked() async throws {
            spy.stubbedPhotos = [ProgressPhoto(date: .now, angle: .front, imageData: Data())]
            let result = try await sut.fetchPhotos()
            #expect(spy.fetchAllWasCalled == true)
            #expect(result.count == 1)
        }

        @Test("fetchPhotos propagates error")
        func fetchPhotosPropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = ProgressError.loadFailed
            await #expect(throws: ProgressError.self) {
                _ = try await sut.fetchPhotos()
            }
        }

        @Test("deletePhoto delegates to repository")
        func deletePhotoTracked() async throws {
            let photo = ProgressPhoto(date: .now, angle: .front, imageData: Data())
            try await sut.deletePhoto(photo)
            #expect(spy.deleteWasCalled == true)
            #expect(spy.lastDeletedPhoto?.id == photo.id)
        }
    }
}

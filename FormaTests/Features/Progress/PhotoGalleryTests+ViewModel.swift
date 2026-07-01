//
//  PhotoGalleryTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension PhotoGalleryTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: PhotoGalleryViewModel
        let spy: SpyPhotoGalleryInteractor

        init() {
            spy = SpyPhotoGalleryInteractor()
            sut = PhotoGalleryViewModel(interactor: spy)
        }

        @Test("load() fetches photos and populates the list")
        func loadSuccess() async {
            spy.stubbedPhotos = [makePhoto()]
            await sut.load()
            #expect(spy.fetchPhotosWasCalled == true)
            #expect(sut.photos.count == 1)
            #expect(sut.isLoading == false)
        }

        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = ProgressError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == ProgressError.loadFailed.errorDescription)
        }

        @Test("delete() removes the photo and reloads")
        func deleteSuccess() async {
            let photo = makePhoto()
            spy.stubbedPhotos = [photo]
            await sut.load()
            spy.stubbedPhotos = []
            await sut.delete(photo)
            #expect(spy.deletePhotoWasCalled == true)
            #expect(spy.lastDeletedPhoto?.id == photo.id)
            #expect(sut.photos.isEmpty)
        }

        @Test("groupedPhotos groups photos by month and year")
        func groupedPhotos() async {
            spy.stubbedPhotos = [makePhoto(angle: .front), makePhoto(angle: .back)]
            await sut.load()
            #expect(sut.groupedPhotos.count == 1)
            #expect(sut.groupedPhotos.first?.photos.count == 2)
        }
    }
}

// MARK: - Test Helpers

private extension PhotoGalleryTests.ViewModelTests {
    func makePhoto(angle: PhotoAngle = .front) -> ProgressPhoto {
        ProgressPhoto(date: .now, angle: angle, imageData: Data())
    }
}

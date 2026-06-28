//
//  MockPhotoGalleryInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockPhotoGalleryInteractor: PhotoGalleryInteractorProtocol {
    
    // MARK: - Stub Data
    
    var stubbedPhotos: [ProgressPhoto] = []
    var shouldThrowOnFetch = false
    var shouldThrowOnDelete = false
    
    // MARK: - Functions
    
    func fetchPhotos() async throws -> [ProgressPhoto] {
        if shouldThrowOnFetch { throw ProgressError.loadFailed }
        return stubbedPhotos
    }
    
    func deletePhoto(_ photo: ProgressPhoto) async throws {
        if shouldThrowOnDelete { throw ProgressError.deleteFailed }
        stubbedPhotos.removeAll { $0.id == photo.id }
    }
}

//
//  PhotoGalleryInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class PhotoGalleryInteractor: PhotoGalleryInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let repository: ProgressPhotoRepositoryProtocol
    
    // MARK: - Initializers
    
    init(repository: ProgressPhotoRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Functions
    
    func fetchPhotos() async throws -> [ProgressPhoto] {
        try await repository.fetchAll()
    }
    
    func deletePhoto(_ photo: ProgressPhoto) async throws {
        try await repository.delete(photo)
    }
}

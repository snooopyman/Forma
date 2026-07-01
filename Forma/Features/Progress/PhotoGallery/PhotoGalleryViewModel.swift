//
//  PhotoGalleryViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 5/4/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class PhotoGalleryViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: PhotoGalleryInteractorProtocol
    
    // MARK: - States
    
    var photos: [ProgressPhoto] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var groupedPhotos: [(header: String, photos: [ProgressPhoto])] {
        var groups: [(header: String, photos: [ProgressPhoto])] = []
        var currentHeader = ""
        var currentPhotos: [ProgressPhoto] = []
        
        for photo in photos {
            let header = photo.date.formatted(.dateTime.month(.wide).year())
            if header != currentHeader {
                if !currentPhotos.isEmpty {
                    groups.append((header: currentHeader, photos: currentPhotos))
                }
                currentHeader = header
                currentPhotos = []
            }
            currentPhotos.append(photo)
        }
        if !currentPhotos.isEmpty {
            groups.append((header: currentHeader, photos: currentPhotos.sorted { $0.angle.sortOrder < $1.angle.sortOrder }))
        }
        return groups
    }
    
    // MARK: - Initializers
    
    init(interactor: PhotoGalleryInteractorProtocol) {
        self.interactor = interactor
    }
    
    // MARK: - Functions
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            photos = try await interactor.fetchPhotos()
        } catch {
            handleError(error)
        }
    }
    
    func delete(_ photo: ProgressPhoto) async {
        do {
            try await interactor.deletePhoto(photo)
        } catch {
            handleError(error)
        }
        await load()
    }
    
    // MARK: - Private Functions
    
    private func handleError(_ error: Error) {
        Logger.progress.error("Error: \(error, privacy: .private)")
        if let progressError = error as? ProgressError {
            errorMessage = progressError.errorDescription
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}

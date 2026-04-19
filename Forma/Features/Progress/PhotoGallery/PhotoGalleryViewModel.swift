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
    private let repository: ProgressPhotoRepositoryProtocol

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

    init(repository: ProgressPhotoRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Functions

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            photos = try await repository.fetchAll()
        } catch {
            Logger.progress.error("Failed to load photos: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func delete(_ photo: ProgressPhoto) async {
        do {
            try await repository.delete(photo)
        } catch {
            Logger.progress.error("Failed to delete photo: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
        await load()
    }
}

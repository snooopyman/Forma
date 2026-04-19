//
//  ProgressPhotoRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 5/4/26.
//

import Foundation
import SwiftData

final class ProgressPhotoRepository: ProgressPhotoRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [ProgressPhoto] {
        let descriptor = FetchDescriptor<ProgressPhoto>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func save(_ photo: ProgressPhoto) async throws {
        modelContext.insert(photo)
        try modelContext.save()
    }

    func delete(_ photo: ProgressPhoto) async throws {
        modelContext.delete(photo)
        try modelContext.save()
    }
}

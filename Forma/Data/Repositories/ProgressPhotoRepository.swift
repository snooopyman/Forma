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
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            throw ProgressError.loadFailed
        }
    }
    
    func save(_ photo: ProgressPhoto) async throws {
        modelContext.insert(photo)
        do {
            try modelContext.save()
        }
        catch {
            throw ProgressError.saveFailed
        }
    }
    
    func delete(_ photo: ProgressPhoto) async throws {
        modelContext.delete(photo)
        do {
            try modelContext.save()
        }
        catch {
            throw ProgressError.deleteFailed
        }
    }
}

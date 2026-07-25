//
//  MuscleVolumeTargetRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import Foundation
import SwiftData

final class MuscleVolumeTargetRepository: MuscleVolumeTargetRepositoryProtocol {
    
    nonisolated(unsafe) private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() async throws -> [MuscleVolumeTarget] {
        let descriptor = FetchDescriptor<MuscleVolumeTarget>()
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            throw ProgressError.loadFailed
        }
    }
    
    func save(_ target: MuscleVolumeTarget) async throws {
        modelContext.insert(target)
        do {
            try modelContext.save()
        }
        catch {
            throw ProgressError.saveFailed
        }
    }
    
    func delete(_ target: MuscleVolumeTarget) async throws {
        modelContext.delete(target)
        do {
            try modelContext.save()
        }
        catch {
            throw ProgressError.deleteFailed
        }
    }
}

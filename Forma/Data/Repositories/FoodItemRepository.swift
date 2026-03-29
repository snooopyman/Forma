//
//  FoodItemRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

final class FoodItemRepository: FoodItemRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodItem>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func search(query: String) async throws -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { $0.name.localizedStandardContains(query) },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func save(_ item: FoodItem) async throws {
        modelContext.insert(item)
        try modelContext.save()
    }

    func delete(_ item: FoodItem) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }
}

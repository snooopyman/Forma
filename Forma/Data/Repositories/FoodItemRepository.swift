//
//  FoodItemRepository.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

final class FoodItemRepository: FoodItemRepositoryProtocol {
    
    nonisolated(unsafe) private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() async throws -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodItem>(
            sortBy: [SortDescriptor(\.name)]
        )
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            throw NutritionError.loadFailed
        }
    }
    
    func search(query: String) async throws -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { $0.name.localizedStandardContains(query) },
            sortBy: [SortDescriptor(\.name)]
        )
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            throw NutritionError.loadFailed
        }
    }
    
    func usageCount(for item: FoodItem) async throws -> Int {
        let itemID = item.id
        let descriptor = FetchDescriptor<MealOptionItem>(
            predicate: #Predicate { $0.foodItem?.id == itemID }
        )
        do {
            return try modelContext.fetchCount(descriptor)
        }
        catch {
            throw NutritionError.loadFailed
        }
    }
    
    func save(_ item: FoodItem) async throws {
        modelContext.insert(item)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.saveFailed
        }
    }
    
    func delete(_ item: FoodItem) async throws {
        modelContext.delete(item)
        do {
            try modelContext.save()
        }
        catch {
            throw NutritionError.deleteFailed
        }
    }
}

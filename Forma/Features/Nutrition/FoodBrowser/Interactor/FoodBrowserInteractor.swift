//
//  FoodBrowserInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class FoodBrowserInteractor: FoodBrowserInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let foodItemRepository: FoodItemRepositoryProtocol
    
    // MARK: - Initializers
    
    init(foodItemRepository: FoodItemRepositoryProtocol) {
        self.foodItemRepository = foodItemRepository
    }
    
    // MARK: - Functions
    
    func fetchAllItems() async throws -> [FoodItem] {
        try await foodItemRepository.fetchAll()
    }
    
    func saveItem(_ item: FoodItem) async throws {
        try await foodItemRepository.save(item)
    }
    
    func deleteItem(_ item: FoodItem) async throws {
        let usageCount = try await foodItemRepository.usageCount(for: item)
        guard usageCount == 0 else {
            throw NutritionError.inUse(count: usageCount)
        }
        try await foodItemRepository.delete(item)
    }
}

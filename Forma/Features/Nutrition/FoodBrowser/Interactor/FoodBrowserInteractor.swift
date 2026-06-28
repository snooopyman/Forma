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
}

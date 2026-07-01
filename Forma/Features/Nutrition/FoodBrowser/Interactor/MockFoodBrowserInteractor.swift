//
//  MockFoodBrowserInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockFoodBrowserInteractor: FoodBrowserInteractorProtocol {

    // MARK: - Stub Data

    nonisolated(unsafe) var stubbedItems: [FoodItem] = []
    nonisolated(unsafe) var shouldThrow = false

    // MARK: - Functions

    func fetchAllItems() async throws -> [FoodItem] {
        if shouldThrow { throw NutritionError.loadFailed }
        return stubbedItems
    }
}

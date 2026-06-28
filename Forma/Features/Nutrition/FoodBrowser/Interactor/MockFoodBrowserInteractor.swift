//
//  MockFoodBrowserInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockFoodBrowserInteractor: FoodBrowserInteractorProtocol {

    // MARK: - Stub Data

    var stubbedItems: [FoodItem] = []
    var shouldThrow = false

    // MARK: - Functions

    func fetchAllItems() async throws -> [FoodItem] {
        if shouldThrow { throw NutritionError.loadFailed }
        return stubbedItems
    }
}

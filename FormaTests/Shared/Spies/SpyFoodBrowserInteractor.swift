//
//  SpyFoodBrowserInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyFoodBrowserInteractor: FoodBrowserInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var fetchAllItemsWasCalled = false

    // MARK: - Stub Data

    var stubbedItems: [FoodItem] = []
    var shouldThrowError = false
    var errorToThrow: Error = NutritionError.loadFailed

    // MARK: - Functions

    func reset() {
        fetchAllItemsWasCalled = false
    }

    func fetchAllItems() async throws -> [FoodItem] {
        fetchAllItemsWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedItems
    }
}

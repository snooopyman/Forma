//
//  SpyFoodItemRepository.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyFoodItemRepository: FoodItemRepositoryProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var fetchAllWasCalled = false
    private(set) var searchWasCalled = false
    private(set) var saveWasCalled = false
    private(set) var deleteWasCalled = false
    private(set) var lastSearchQuery: String?
    private(set) var lastSavedItem: FoodItem?
    private(set) var lastDeletedItem: FoodItem?

    // MARK: - Stub Data

    var stubbedItems: [FoodItem] = []
    var shouldThrowError = false
    var errorToThrow: Error = NutritionError.loadFailed

    // MARK: - Functions

    func reset() {
        fetchAllWasCalled = false
        searchWasCalled = false
        saveWasCalled = false
        deleteWasCalled = false
        lastSearchQuery = nil
        lastSavedItem = nil
        lastDeletedItem = nil
    }

    func fetchAll() async throws -> [FoodItem] {
        fetchAllWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedItems
    }

    func search(query: String) async throws -> [FoodItem] {
        searchWasCalled = true
        lastSearchQuery = query
        if shouldThrowError { throw errorToThrow }
        return stubbedItems
    }

    func save(_ item: FoodItem) async throws {
        saveWasCalled = true
        lastSavedItem = item
        if shouldThrowError { throw errorToThrow }
    }

    func delete(_ item: FoodItem) async throws {
        deleteWasCalled = true
        lastDeletedItem = item
        if shouldThrowError { throw errorToThrow }
    }
}

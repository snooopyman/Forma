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
    private(set) var saveItemWasCalled = false
    private(set) var deleteItemWasCalled = false
    private(set) var lastSavedItem: FoodItem?
    private(set) var lastDeletedItem: FoodItem?
    
    // MARK: - Stub Data
    
    var stubbedItems: [FoodItem] = []
    var shouldThrowError = false
    var errorToThrow: Error = NutritionError.loadFailed
    
    // MARK: - Functions
    
    func reset() {
        fetchAllItemsWasCalled = false
        saveItemWasCalled = false
        deleteItemWasCalled = false
        lastSavedItem = nil
        lastDeletedItem = nil
    }
    
    func fetchAllItems() async throws -> [FoodItem] {
        fetchAllItemsWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedItems
    }
    
    func saveItem(_ item: FoodItem) async throws {
        saveItemWasCalled = true
        lastSavedItem = item
        if shouldThrowError { throw errorToThrow }
    }
    
    func deleteItem(_ item: FoodItem) async throws {
        deleteItemWasCalled = true
        lastDeletedItem = item
        if shouldThrowError { throw errorToThrow }
    }
}

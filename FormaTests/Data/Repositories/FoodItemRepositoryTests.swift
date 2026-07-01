//
//  FoodItemRepositoryTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
import SwiftData
@testable import Forma

@Suite("Food Item Repository Tests")
@MainActor
struct FoodItemRepositoryTests {

    // MARK: - Properties

    let sut: FoodItemRepository
    let modelContainer: ModelContainer

    // MARK: - Initializers

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: FoodItem.self,
            configurations: config
        )
        sut = FoodItemRepository(modelContext: modelContainer.mainContext)
    }

    // MARK: - fetchAll

    @Test("fetchAll returns empty when no food items")
    func fetchAllEmpty() async throws {
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }

    @Test("fetchAll returns all saved items sorted by name")
    func fetchAllSortedByName() async throws {
        let zucchini = Self.makeFoodItem(name: "Zucchini")
        let apple = Self.makeFoodItem(name: "Apple")
        try await sut.save(zucchini)
        try await sut.save(apple)
        let result = try await sut.fetchAll()
        #expect(result.count == 2)
        #expect(result.first?.name == "Apple")
    }

    // MARK: - search

    @Test("search returns items matching query")
    func searchMatchesQuery() async throws {
        try await sut.save(Self.makeFoodItem(name: "Chicken breast"))
        try await sut.save(Self.makeFoodItem(name: "Chicken thigh"))
        try await sut.save(Self.makeFoodItem(name: "Rice"))
        let result = try await sut.search(query: "chicken")
        #expect(result.count == 2)
    }

    @Test("search returns empty when nothing matches")
    func searchNoMatches() async throws {
        try await sut.save(Self.makeFoodItem(name: "Rice"))
        let result = try await sut.search(query: "chicken")
        #expect(result.isEmpty)
    }

    // MARK: - save / delete round-trip

    @Test("save and fetchAll round-trip preserves macros")
    func saveAndFetch() async throws {
        let item = Self.makeFoodItem(name: "Oats", caloriesPer100g: 389, proteinPer100g: 16.9)
        try await sut.save(item)
        let result = try await sut.fetchAll()
        #expect(result.count == 1)
        #expect(result.first?.caloriesPer100g == 389)
        #expect(result.first?.proteinPer100g == 16.9)
    }

    @Test("delete removes item from store")
    func deleteItem() async throws {
        let item = Self.makeFoodItem(name: "Oats")
        try await sut.save(item)
        try await sut.delete(item)
        let result = try await sut.fetchAll()
        #expect(result.isEmpty)
    }
}

// MARK: - Test Data

private extension FoodItemRepositoryTests {
    static func makeFoodItem(
        name: String,
        caloriesPer100g: Double = 100,
        proteinPer100g: Double = 10
    ) -> FoodItem {
        FoodItem(
            name: name,
            category: "General",
            mainMacro: .protein,
            caloriesPer100g: caloriesPer100g,
            proteinPer100g: proteinPer100g,
            carbsPer100g: 5,
            fatPer100g: 2
        )
    }
}

//
//  AppContainerTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 25/7/26.
//

import Testing
import Foundation
import SwiftData
@testable import Forma

@Suite("App Container Tests")
@MainActor
struct AppContainerTests {
    
    @Test("Custom food items survive the catalog reconciliation")
    func customFoodItemsSurviveReconciliation() async throws {
        let modelContainer = try Self.makeInMemoryContainer()
        let modelContext = modelContainer.mainContext
        
        let customItem = FoodItem(
            name: "Grandma's soup",
            category: "Custom",
            mainMacro: .protein,
            caloriesPer100g: 80,
            proteinPer100g: 5,
            carbsPer100g: 8,
            fatPer100g: 2,
            isCustom: true
        )
        modelContext.insert(customItem)
        try modelContext.save()
        
        _ = AppContainer(modelContext: modelContext)
        
        let survivingCustomItems = try modelContext.fetch(
            FetchDescriptor<FoodItem>(predicate: #Predicate { $0.isCustom })
        )
        #expect(survivingCustomItems.contains { $0.name == "Grandma's soup" })
        
        let allItems = try modelContext.fetch(FetchDescriptor<FoodItem>())
        #expect(allItems.count == FoodCatalog.catalog.count + 1)
    }
    
    @Test("Reconciliation backfills catalogKey/categoryKey onto already-seeded rows without touching custom items")
    func reconciliationBackfillsLocalizationKeys() async throws {
        let modelContainer = try Self.makeInMemoryContainer()
        let modelContext = modelContainer.mainContext

        let catalogEntry = FoodCatalog.catalog.first!

        // Simulates a pre-localization install: the row already exists (same name),
        // seeded before catalogKey/categoryKey existed, so both are nil.
        let preExistingItem = FoodItem(
            name: catalogEntry.name,
            category: catalogEntry.category,
            mainMacro: catalogEntry.mainMacro,
            caloriesPer100g: catalogEntry.caloriesPer100g,
            proteinPer100g: catalogEntry.proteinPer100g,
            carbsPer100g: catalogEntry.carbsPer100g,
            fatPer100g: catalogEntry.fatPer100g
        )
        modelContext.insert(preExistingItem)

        let customItem = FoodItem(
            name: "Grandma's soup",
            category: "Custom",
            mainMacro: .protein,
            caloriesPer100g: 80,
            proteinPer100g: 5,
            carbsPer100g: 8,
            fatPer100g: 2,
            isCustom: true
        )
        modelContext.insert(customItem)
        try modelContext.save()

        #expect(preExistingItem.catalogKey == nil)
        #expect(preExistingItem.categoryKey == nil)

        _ = AppContainer(modelContext: modelContext)

        let catalogEntryName = catalogEntry.name
        let backfilled = try modelContext.fetch(
            FetchDescriptor<FoodItem>(predicate: #Predicate { $0.name == catalogEntryName })
        ).first
        #expect(backfilled?.catalogKey == catalogEntry.catalogKey)
        #expect(backfilled?.categoryKey == catalogEntry.categoryKey)

        let survivingCustomItem = try modelContext.fetch(
            FetchDescriptor<FoodItem>(predicate: #Predicate { $0.name == "Grandma's soup" })
        ).first
        #expect(survivingCustomItem?.catalogKey == nil)
        #expect(survivingCustomItem?.categoryKey == nil)
        #expect(survivingCustomItem?.category == "Custom")
    }

    @Test("Reconciliation is idempotent across repeated launches")
    func reconciliationIsIdempotent() async throws {
        let modelContainer = try Self.makeInMemoryContainer()
        let modelContext = modelContainer.mainContext
        
        _ = AppContainer(modelContext: modelContext)
        _ = AppContainer(modelContext: modelContext)
        _ = AppContainer(modelContext: modelContext)
        
        let allItems = try modelContext.fetch(FetchDescriptor<FoodItem>())
        #expect(allItems.count == FoodCatalog.catalog.count)
    }
    
    @Test("Reconciliation deduplicates non-custom items that share the same name")
    func reconciliationDeduplicatesExistingDuplicates() async throws {
        let modelContainer = try Self.makeInMemoryContainer()
        let modelContext = modelContainer.mainContext
        
        // Simulates two devices independently re-seeding the catalog with fresh UUIDs
        // (e.g. after a reinstall), producing CloudKit-merged duplicates by name.
        let duplicatedName = FoodCatalog.catalog.first!.name
        modelContext.insert(FoodItem(name: duplicatedName, category: "Carne", mainMacro: .protein, caloriesPer100g: 100, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 2))
        modelContext.insert(FoodItem(name: duplicatedName, category: "Carne", mainMacro: .protein, caloriesPer100g: 100, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 2))
        try modelContext.save()
        
        _ = AppContainer(modelContext: modelContext)
        
        let allItems = try modelContext.fetch(FetchDescriptor<FoodItem>())
        #expect(allItems.filter { $0.name == duplicatedName }.count == 1)
        #expect(allItems.count == FoodCatalog.catalog.count)
    }
    
    @Test("Reconciliation never deletes a food item referenced by a meal plan, even if it's a duplicate")
    func reconciliationPreservesReferencedDuplicate() async throws {
        let modelContainer = try Self.makeInMemoryContainer()
        let modelContext = modelContainer.mainContext
        
        // Simulates the exact crash scenario: a duplicate (or catalog-stale) FoodItem
        // that the user's real nutrition plan still points to via MealOptionItem.
        let duplicatedName = FoodCatalog.catalog.first!.name
        let referencedItem = FoodItem(name: duplicatedName, category: "Carne", mainMacro: .protein, caloriesPer100g: 100, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 2)
        let orphanDuplicate = FoodItem(name: duplicatedName, category: "Carne", mainMacro: .protein, caloriesPer100g: 100, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 2)
        modelContext.insert(referencedItem)
        modelContext.insert(orphanDuplicate)
        
        let mealOptionItem = MealOptionItem(amountGrams: 100)
        mealOptionItem.foodItem = referencedItem
        modelContext.insert(mealOptionItem)
        try modelContext.save()
        
        _ = AppContainer(modelContext: modelContext)
        
        let survivors = try modelContext.fetch(
            FetchDescriptor<FoodItem>(predicate: #Predicate { $0.name == duplicatedName })
        )
        #expect(survivors.count == 1)
        #expect(survivors.first?.id == referencedItem.id)
        #expect(mealOptionItem.foodItem?.id == referencedItem.id)
    }
    
    @Test("Repair leaves a meal option item with a valid food item reference untouched")
    func repairLeavesValidReferenceUntouched() async throws {
        let modelContainer = try Self.makeInMemoryContainer()
        let modelContext = modelContainer.mainContext
        
        let item = FoodItem(name: "Real food", category: "Carne", mainMacro: .protein, caloriesPer100g: 100, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 2, isCustom: true)
        modelContext.insert(item)
        let mealOptionItem = MealOptionItem(amountGrams: 100)
        mealOptionItem.foodItem = item
        modelContext.insert(mealOptionItem)
        try modelContext.save()
        
        _ = AppContainer(modelContext: modelContext)
        
        #expect(mealOptionItem.foodItem?.id == item.id)
    }
    
    @Test("Repair leaves a meal option item with no food item untouched")
    func repairLeavesNilReferenceUntouched() async throws {
        let modelContainer = try Self.makeInMemoryContainer()
        let modelContext = modelContainer.mainContext
        
        let mealOptionItem = MealOptionItem(amountGrams: 100)
        modelContext.insert(mealOptionItem)
        try modelContext.save()
        
        _ = AppContainer(modelContext: modelContext)
        
        #expect(mealOptionItem.foodItem == nil)
    }
    
    // MARK: - Test Helpers
    
    private static func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema(FormaSchema.models)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}

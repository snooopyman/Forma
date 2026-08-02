//
//  FoodBrowserViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class FoodBrowserViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: FoodBrowserInteractorProtocol
    
    // MARK: - States
    
    var searchText = ""
    var selectedCategory: String?
    var allItems: [FoodItem] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var categories: [String] {
        Array(Set(allItems.map { $0.category })).sorted()
    }
    
    var filteredItems: [FoodItem] {
        var items = allItems
        if let cat = selectedCategory {
            items = items.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedStandardContains(searchText) }
        }
        return items
    }
    
    // MARK: - Initializers
    
    init(interactor: FoodBrowserInteractorProtocol) {
        self.interactor = interactor
    }
    
    // MARK: - Functions
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            allItems = try await interactor.fetchAllItems()
        } catch {
            handleError(error)
        }
    }
    
    func isDuplicateName(_ name: String, excludingID: UUID?) -> Bool {
        allItems.contains {
            $0.name.caseInsensitiveCompare(name) == .orderedSame && $0.id != excludingID
        }
    }
    
    @discardableResult
    func saveItem(_ item: FoodItem) async -> Bool {
        do {
            try await interactor.saveItem(item)
            await load()
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    func deleteItem(_ item: FoodItem) async {
        do {
            try await interactor.deleteItem(item)
            await load()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Functions
    
    private func handleError(_ error: Error) {
        Logger.nutrition.error("Error: \(error, privacy: .private)")
        if let nutritionError = error as? NutritionError {
            errorMessage = nutritionError.errorDescription
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}

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
    private let repository: FoodItemRepositoryProtocol

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

    init(repository: FoodItemRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Functions

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            allItems = try await repository.fetchAll()
        } catch {
            Logger.nutrition.error("Failed to load food items: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }
}

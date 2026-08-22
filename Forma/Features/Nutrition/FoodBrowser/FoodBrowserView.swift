//
//  FoodBrowserView.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import SwiftUI

struct FoodBrowserView: View {
    
    // MARK: - Private Properties
    
    @State private var viewModel: FoodBrowserViewModel
    @State private var showingAddFood = false
    @State private var editingItem: FoodItem?
    
    // MARK: - Initializers
    
    init(repository: FoodItemRepositoryProtocol) {
        let interactor = FoodBrowserInteractor(foodItemRepository: repository)
        _viewModel = State(initialValue: FoodBrowserViewModel(interactor: interactor))
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredItems.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .background(.backgroundPrimary)
        .navigationTitle(String(localized: "Food browser"))
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: String(localized: "Search foods")
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddFood = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddFood) {
            FoodItemEditorView(viewModel: viewModel)
        }
        .sheet(item: $editingItem) { item in
            FoodItemEditorView(editing: item, viewModel: viewModel)
        }
        .alert(
            String(localized: "Error"),
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
        .task { await viewModel.load() }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            categoryFilter
            foodList
        }
    }
    
    @ViewBuilder
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                CategoryChip(
                    title: String(localized: "All"),
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory =
                        viewModel.selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.sm)
        }
    }
    
    @ViewBuilder
    private var foodList: some View {
        List(viewModel.filteredItems) { item in
            FoodBrowserRow(item: item)
                .listRowBackground(Color(.backgroundCard))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if item.isCustom {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteItem(item) }
                        } label: {
                            Label(String(localized: "Delete"), systemImage: "trash")
                        }
                    }
                }
                .swipeActions(edge: .leading) {
                    if item.isCustom {
                        Button {
                            editingItem = item
                        } label: {
                            Label(String(localized: "Edit"), systemImage: "pencil")
                        }
                        .tint(.accent)
                    }
                }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var emptyView: some View {
        ContentUnavailableView.search(text: viewModel.searchText)
    }
}

// MARK: - CategoryChip

private struct CategoryChip: View {
    
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Color(.textOnAccent) : Color(.textPrimary))
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.xs)
                .background(isSelected ? Color(.accent) : Color(.backgroundCard))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
        }
    }
}

// MARK: - FoodBrowserRow

private struct FoodBrowserRow: View {
    
    let item: FoodItem
    
    private var mainMacroColor: Color {
        switch item.mainMacro {
        case .protein: return Color(.macroProtein)
        case .carbs:   return Color(.macroCarbs)
        case .fat:     return Color(.macroFat)
        }
    }
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            RoundedRectangle(cornerRadius: DS.Radius.inner)
                .fill(mainMacroColor)
                .frame(width: 4, height: 44)
            
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack(spacing: DS.Spacing.xs) {
                    Text(item.displayName)
                        .font(.body)
                        .foregroundStyle(.textPrimary)
                    if item.isCustom {
                        Text(String(localized: "Custom"))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color(.textOnAccent))
                            .padding(.horizontal, DS.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color(.accent))
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.chip))
                    }
                }
                HStack(spacing: DS.Spacing.xs) {
                    Text(item.displayCategory)
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                    Text(verbatim: "·")
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                    Text(item.mainMacro.localizedName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(mainMacroColor)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                Text(verbatim: "\(item.caloriesPer100g.formatted(.number.precision(.fractionLength(0)))) kcal")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.textSecondary)
                HStack(spacing: DS.Spacing.xs) {
                    macroLabel(value: item.proteinPer100g, color: .macroProtein, prefix: MacroType.protein.abbreviation)
                    macroLabel(value: item.carbsPer100g, color: .macroCarbs, prefix: MacroType.carbs.abbreviation)
                    macroLabel(value: item.fatPer100g, color: .macroFat, prefix: MacroType.fat.abbreviation)
                }
            }
        }
        .padding(.vertical, DS.Spacing.xs)
    }
    
    @ViewBuilder
    private func macroLabel(value: Double, color: Color, prefix: String) -> some View {
        HStack(spacing: 1) {
            Text(verbatim: prefix)
                .foregroundStyle(color)
            Text(verbatim: value.formatted(.number.precision(.fractionLength(0))))
                .foregroundStyle(.textTertiary)
        }
        .font(.caption2.weight(.medium))
    }
}

#Preview("With results", traits: .previewContainer(.withData)) {
    @Previewable @Environment(AppContainer.self) var container
    NavigationStack {
        FoodBrowserView(repository: container.foodItemRepository)
    }
}

#Preview("Empty", traits: .previewContainer(.empty)) {
    @Previewable @Environment(AppContainer.self) var container
    NavigationStack {
        FoodBrowserView(repository: container.foodItemRepository)
    }
}

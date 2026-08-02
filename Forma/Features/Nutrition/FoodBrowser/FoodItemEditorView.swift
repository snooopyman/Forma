//
//  FoodItemEditorView.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import SwiftUI
import SwiftData

struct FoodItemEditorView: View {
    
    // MARK: - Private Properties
    
    private static let customCategoryTag = "__custom__"
    
    private let editingItem: FoodItem?
    private let viewModel: FoodBrowserViewModel
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - States
    
    @State private var name: String
    @State private var brand: String
    @State private var selectedCategory: String
    @State private var customCategory: String
    @State private var mainMacro: MacroType
    @State private var calories: Double
    @State private var protein: Double
    @State private var carbs: Double
    @State private var fat: Double
    @State private var fiber: Double
    @State private var basePortionG: Double
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingDuplicateAlert = false
    
    // MARK: - Computed Properties
    
    private var isEditMode: Bool { editingItem != nil }
    
    private var estimatedCalories: Double {
        protein * 4 + carbs * 4 + fat * 9
    }
    
    private var resolvedCategory: String {
        selectedCategory == Self.customCategoryTag
        ? customCategory.trimmingCharacters(in: .whitespaces)
        : selectedCategory
    }
    
    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty
        || resolvedCategory.isEmpty
        || basePortionG < 1
        || isSaving
    }
    
    // MARK: - Initializers
    
    init(viewModel: FoodBrowserViewModel) {
        self.viewModel = viewModel
        self.editingItem = nil
        _name = State(initialValue: "")
        _brand = State(initialValue: "")
        _selectedCategory = State(initialValue: viewModel.categories.first ?? Self.customCategoryTag)
        _customCategory = State(initialValue: "")
        _mainMacro = State(initialValue: .protein)
        _calories = State(initialValue: 0)
        _protein = State(initialValue: 0)
        _carbs = State(initialValue: 0)
        _fat = State(initialValue: 0)
        _fiber = State(initialValue: 0)
        _basePortionG = State(initialValue: 100)
    }
    
    init(editing item: FoodItem, viewModel: FoodBrowserViewModel) {
        self.viewModel = viewModel
        self.editingItem = item
        _name = State(initialValue: item.name)
        _brand = State(initialValue: item.brand)
        if viewModel.categories.contains(item.category) {
            _selectedCategory = State(initialValue: item.category)
            _customCategory = State(initialValue: "")
        } else {
            _selectedCategory = State(initialValue: Self.customCategoryTag)
            _customCategory = State(initialValue: item.category)
        }
        _mainMacro = State(initialValue: item.mainMacro)
        _calories = State(initialValue: item.caloriesPer100g)
        _protein = State(initialValue: item.proteinPer100g)
        _carbs = State(initialValue: item.carbsPer100g)
        _fat = State(initialValue: item.fatPer100g)
        _fiber = State(initialValue: item.fiberPer100g)
        _basePortionG = State(initialValue: item.basePortionG)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Name"), text: $name)
                    TextField(String(localized: "Brand (optional)"), text: $brand)
                    Picker(String(localized: "Category"), selection: $selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                        Text(String(localized: "Custom category")).tag(Self.customCategoryTag)
                    }
                    if selectedCategory == Self.customCategoryTag {
                        TextField(String(localized: "New category name"), text: $customCategory)
                    }
                    Picker(String(localized: "Main macro"), selection: $mainMacro) {
                        ForEach(MacroType.allCases, id: \.self) { macro in
                            Text(macro.localizedName).tag(macro)
                        }
                    }
                }
                Section(String(localized: "Macros per 100g")) {
                    macroField(String(localized: "Calories"), value: $calories)
                    macroField(String(localized: "Protein (g)"), value: $protein)
                    macroField(String(localized: "Carbs (g)"), value: $carbs)
                    macroField(String(localized: "Fat (g)"), value: $fat)
                    macroField(String(localized: "Fiber (g)"), value: $fiber)
                    Text(String(localized: "Estimated calories from macros: \(estimatedCalories.formatted(.number.precision(.fractionLength(0))))"))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
                Section(String(localized: "Portion")) {
                    macroField(String(localized: "Base portion (g)"), value: $basePortionG)
                }
            }
            .navigationTitle(isEditMode ? String(localized: "Edit food") : String(localized: "New food"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditMode ? String(localized: "Save") : String(localized: "Add")) {
                        Task { await attemptSave() }
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaveDisabled)
                }
            }
            .alert(
                String(localized: "Duplicate name"),
                isPresented: $showingDuplicateAlert
            ) {
                Button(String(localized: "Cancel"), role: .cancel) {}
                Button(String(localized: "Save anyway")) {
                    Task { await performSave() }
                }
            } message: {
                Text(String(localized: "Another food item with this name already exists. Save anyway?"))
            }
            .alert(
                String(localized: "Error"),
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                if let msg = errorMessage { Text(msg) }
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private func macroField(_ title: String, value: Binding<Double>) -> some View {
        LabeledContent(title) {
            TextField(title, value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
    
    // MARK: - Private Functions
    
    private func attemptSave() async {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if viewModel.isDuplicateName(trimmedName, excludingID: editingItem?.id) {
            showingDuplicateAlert = true
        } else {
            await performSave()
        }
    }
    
    private func performSave() async {
        isSaving = true
        defer { isSaving = false }
        let item = buildItem()
        let success = await viewModel.saveItem(item)
        if success {
            dismiss()
        } else {
            errorMessage = viewModel.errorMessage
            viewModel.errorMessage = nil
        }
    }
    
    private func buildItem() -> FoodItem {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedBrand = brand.trimmingCharacters(in: .whitespaces)
        let trimmedCategory = resolvedCategory
        if let editingItem {
            editingItem.name = trimmedName
            editingItem.brand = trimmedBrand
            editingItem.category = trimmedCategory
            editingItem.mainMacro = mainMacro
            editingItem.caloriesPer100g = calories
            editingItem.proteinPer100g = protein
            editingItem.carbsPer100g = carbs
            editingItem.fatPer100g = fat
            editingItem.fiberPer100g = fiber
            editingItem.basePortionG = basePortionG
            return editingItem
        }
        return FoodItem(
            name: trimmedName,
            brand: trimmedBrand,
            category: trimmedCategory,
            mainMacro: mainMacro,
            caloriesPer100g: calories,
            proteinPer100g: protein,
            carbsPer100g: carbs,
            fatPer100g: fat,
            fiberPer100g: fiber,
            basePortionG: basePortionG,
            isCustom: true
        )
    }
}

// MARK: - Previews

private struct FoodItemEditorPreviewWrapper: View {
    @Environment(AppContainer.self) private var container
    @Query private var foodItems: [FoodItem]
    
    let editingExisting: Bool
    
    var body: some View {
        let viewModel = FoodBrowserViewModel(interactor: FoodBrowserInteractor(foodItemRepository: container.foodItemRepository))
        if editingExisting, let item = foodItems.first {
            FoodItemEditorView(editing: item, viewModel: viewModel)
        } else {
            FoodItemEditorView(viewModel: viewModel)
        }
    }
}

#Preview("Add", traits: .previewContainer(.withData)) {
    FoodItemEditorPreviewWrapper(editingExisting: false)
}

#Preview("Edit", traits: .previewContainer(.withData)) {
    FoodItemEditorPreviewWrapper(editingExisting: true)
}

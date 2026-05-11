//
//  MealDetailView.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import SwiftUI

struct MealDetailView: View {

    // MARK: - Private Properties

    private let onLogged: () -> Void

    // MARK: - States

    @State private var viewModel: MealDetailViewModel
    @State private var isEditing = false
    @State private var showFoodPicker = false
    @State private var pickingForOption: MealOption? = nil
    @State private var allFoods: [FoodItem] = []

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(AppContainer.self) private var container

    // MARK: - Initializers

    init(meal: Meal, nutritionRepository: NutritionRepositoryProtocol, onLogged: @escaping () -> Void) {
        _viewModel = State(initialValue: MealDetailViewModel(
            meal: meal,
            nutritionRepository: nutritionRepository
        ))
        self.onLogged = onLogged
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    if viewModel.sortedOptions.isEmpty {
                        emptyOptionsView
                    } else {
                        if viewModel.sortedOptions.count > 1 {
                            optionPicker
                        }
                        if let option = viewModel.selectedOption {
                            optionDetail(option: option)
                        }
                    }

                    if isEditing {
                        editingControls
                    }
                }
                .padding(DS.Spacing.lg)
            }
            .navigationTitle(viewModel.meal.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? String(localized: "Done") : String(localized: "Edit")) {
                        isEditing.toggle()
                    }
                    .fontWeight(isEditing ? .semibold : .regular)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !isEditing {
                    logButton.padding(DS.Spacing.lg)
                }
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
            .sheet(isPresented: $showFoodPicker, onDismiss: { pickingForOption = nil }) {
                FoodPickerSheet(foods: allFoods) { food, grams in
                    if let option = pickingForOption {
                        Task { await viewModel.addFoodItem(food, grams: grams, to: option) }
                    }
                }
            }
            .task {
                await viewModel.load()
                allFoods = (try? await container.foodItemRepository.fetchAll()) ?? []
            }
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var emptyOptionsView: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "fork.knife")
                .font(.system(size: 40))
                .foregroundStyle(.textTertiary)
            Text(String(localized: "No options yet"))
                .font(.headline)
                .foregroundStyle(.textSecondary)
            Text(String(localized: "Tap Edit to add options and foods"))
                .font(.subheadline)
                .foregroundStyle(.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(DS.Spacing.xxl)
    }

    @ViewBuilder
    private var optionPicker: some View {
        VStack(spacing: DS.Spacing.sm) {
            Picker(String(localized: "Option"), selection: $viewModel.selectedOptionIndex) {
                ForEach(viewModel.sortedOptions.indices, id: \.self) { idx in
                    Text(String(localized: "Option \(idx + 1)")).tag(idx)
                }
            }
            .pickerStyle(.segmented)

            Button {
                if !viewModel.isSelectedOptionPreferred {
                    Task { await viewModel.setPreferredOption() }
                }
            } label: {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: viewModel.isSelectedOptionPreferred ? "star.fill" : "star")
                        .font(.subheadline)
                    Text(
                        viewModel.isSelectedOptionPreferred
                            ? String(localized: "Shown in overview")
                            : String(localized: "Show in overview")
                    )
                    .font(.subheadline.weight(.medium))
                    Spacer()
                    if viewModel.isSelectedOptionPreferred {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.semibold))
                    }
                }
                .foregroundStyle(viewModel.isSelectedOptionPreferred ? Color.accent : Color.textSecondary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(
                    viewModel.isSelectedOptionPreferred
                        ? Color.accent.opacity(0.1)
                        : Color.backgroundSecondary
                )
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
            }
            .disabled(viewModel.isSelectedOptionPreferred)
        }
    }

    @ViewBuilder
    private func optionDetail(option: MealOption) -> some View {
        VStack(spacing: DS.Spacing.md) {
            macroSummaryCard(option: option)
            itemsCard(option: option)
        }
    }

    @ViewBuilder
    private func macroSummaryCard(option: MealOption) -> some View {
        HStack(spacing: 0) {
            macroCell(
                label: String(localized: "Calories"),
                value: option.totalCalories.formatted(.number.precision(.fractionLength(0))),
                unit: "kcal",
                color: .accent
            )
            Divider().frame(height: 40)
            macroCell(
                label: String(localized: "Protein"),
                value: option.totalProteinG.formatted(.number.precision(.fractionLength(1))),
                unit: "g",
                color: .macroProtein
            )
            Divider().frame(height: 40)
            macroCell(
                label: String(localized: "Carbs"),
                value: option.totalCarbsG.formatted(.number.precision(.fractionLength(1))),
                unit: "g",
                color: .macroCarbs
            )
            Divider().frame(height: 40)
            macroCell(
                label: String(localized: "Fat"),
                value: option.totalFatG.formatted(.number.precision(.fractionLength(1))),
                unit: "g",
                color: .macroFat
            )
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }

    @ViewBuilder
    private func macroCell(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.textSecondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(verbatim: value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(color)
                Text(verbatim: unit)
                    .font(.caption2)
                    .foregroundStyle(.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func itemsCard(option: MealOption) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String(localized: "Foods"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textSecondary)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.top, DS.Spacing.md)
                .padding(.bottom, DS.Spacing.sm)

            let sorted = option.items.sorted { $0.id.uuidString < $1.id.uuidString }
            ForEach(sorted) { item in
                FoodItemRow(item: item, isEditing: isEditing) {
                    Task { await viewModel.deleteFoodItem(item) }
                }
                if item.id != sorted.last?.id {
                    Divider().padding(.leading, DS.Spacing.md)
                }
            }

            if isEditing {
                Divider().padding(.leading, DS.Spacing.md)
                Button {
                    pickingForOption = option
                    showFoodPicker = true
                } label: {
                    Label(String(localized: "Add food"), systemImage: "plus")
                        .font(.subheadline)
                        .foregroundStyle(.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DS.Spacing.md)
                        .padding(.vertical, DS.Spacing.sm)
                }
            }
        }
        .cardStyle()
    }

    @ViewBuilder
    private var editingControls: some View {
        VStack(spacing: DS.Spacing.md) {
            if viewModel.sortedOptions.count < 3 {
                Button {
                    Task { await viewModel.addOption() }
                } label: {
                    Label(
                        String(localized: "Add option \(viewModel.sortedOptions.count + 1)"),
                        systemImage: "plus.circle"
                    )
                    .glassButtonLabel()
                }
                .buttonStyle(.glass)
            }

            if let option = viewModel.selectedOption, viewModel.sortedOptions.count > 1 {
                Button(role: .destructive) {
                    Task { await viewModel.deleteOption(option) }
                } label: {
                    Label(
                        String(localized: "Delete option \(viewModel.selectedOptionIndex + 1)"),
                        systemImage: "trash"
                    )
                    .glassButtonLabel()
                    .foregroundStyle(.error)
                }
                .buttonStyle(.glass)
            }
        }
    }

    @ViewBuilder
    private var logButton: some View {
        if viewModel.isLogged {
            Button {
                Task {
                    await viewModel.unlog()
                    onLogged()
                    dismiss()
                }
            } label: {
                Text(String(localized: "Unlog"))
                    .glassButtonLabel()
            }
            .buttonStyle(.glass)
        } else {
            Button {
                Task {
                    await viewModel.logSelectedOption()
                    onLogged()
                    dismiss()
                }
            } label: {
                Text(String(localized: "Mark as done"))
                    .primaryButtonLabel()
            }
            .buttonStyle(.glassProminent)
            .tint(.accent)
            .disabled(viewModel.selectedOption == nil)
        }
    }
}

// MARK: - FoodItemRow

private struct FoodItemRow: View {

    let item: MealOptionItem
    let isEditing: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            if isEditing {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.error)
                        .font(.title3)
                }
            }

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(item.foodItem?.name ?? "")
                    .font(.body)
                    .foregroundStyle(.textPrimary)
                Text(verbatim: "\(item.amountGrams.formatted(.number.precision(.fractionLength(0)))) g")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            if let food = item.foodItem {
                VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                    Text(verbatim: "\(food.calories(forGrams: item.amountGrams).formatted(.number.precision(.fractionLength(0)))) kcal")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.textSecondary)
                    HStack(spacing: DS.Spacing.xs) {
                        Text(verbatim: "P \(food.protein(forGrams: item.amountGrams).formatted(.number.precision(.fractionLength(0))))g")
                            .font(.caption2)
                            .foregroundStyle(.macroProtein)
                        Text(verbatim: "C \(food.carbs(forGrams: item.amountGrams).formatted(.number.precision(.fractionLength(0))))g")
                            .font(.caption2)
                            .foregroundStyle(.macroCarbs)
                        Text(verbatim: "F \(food.fat(forGrams: item.amountGrams).formatted(.number.precision(.fractionLength(0))))g")
                            .font(.caption2)
                            .foregroundStyle(.macroFat)
                    }
                }
            }
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .animation(.default, value: isEditing)
    }
}

// MARK: - FoodPickerSheet

private struct FoodPickerSheet: View {

    // MARK: - Private Properties

    @State private var searchText = ""
    @State private var selectedFood: FoodItem? = nil
    @State private var amountText = ""

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let foods: [FoodItem]
    let onConfirm: (FoodItem, Double) -> Void

    // MARK: - Computed Properties

    private var filtered: [FoodItem] {
        searchText.isEmpty
            ? foods.sorted { $0.name < $1.name }
            : foods.filter { $0.name.localizedStandardContains(searchText) }
    }

    private var canConfirm: Bool {
        Double(amountText.replacingOccurrences(of: ",", with: ".")) != nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List(filtered) { food in
                FoodPickerRow(food: food)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedFood = food
                        amountText = food.basePortionG.formatted(.number.precision(.fractionLength(0)))
                    }
                    .listRowBackground(Color(.backgroundCard))
            }
            .listStyle(.plain)
            .navigationTitle(String(localized: "Add food"))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: String(localized: "Search foods")
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
            }
            .alert(
                String(localized: "Amount (g)"),
                isPresented: Binding(
                    get: { selectedFood != nil },
                    set: { if !$0 { selectedFood = nil } }
                )
            ) {
                TextField(String(localized: "Grams"), text: $amountText)
                    .keyboardType(.decimalPad)
                Button(String(localized: "Add")) {
                    guard let food = selectedFood,
                          let grams = Double(amountText.replacingOccurrences(of: ",", with: ".")) else { return }
                    onConfirm(food, grams)
                    dismiss()
                }
                .disabled(!canConfirm)
                Button(String(localized: "Cancel"), role: .cancel) {
                    selectedFood = nil
                }
            } message: {
                if let food = selectedFood {
                    Text(verbatim: "\(food.name) · \(food.proteinPer100g.formatted(.number.precision(.fractionLength(0))))P \(food.carbsPer100g.formatted(.number.precision(.fractionLength(0))))C \(food.fatPer100g.formatted(.number.precision(.fractionLength(0))))F /100g")
                }
            }
        }
    }
}

// MARK: - FoodPickerRow

private struct FoodPickerRow: View {

    let food: FoodItem

    private var macroColor: Color {
        switch food.mainMacro {
        case .protein: return .macroProtein
        case .carbs:   return .macroCarbs
        case .fat:     return .macroFat
        }
    }

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            RoundedRectangle(cornerRadius: DS.Radius.inner)
                .fill(macroColor)
                .frame(width: 4, height: 40)

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(food.name)
                    .font(.body)
                    .foregroundStyle(.textPrimary)
                Text(food.category)
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                Text(verbatim: "\(food.caloriesPer100g.formatted(.number.precision(.fractionLength(0)))) kcal")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.textSecondary)
                HStack(spacing: DS.Spacing.xs) {
                    macroLabel(value: food.proteinPer100g, color: .macroProtein, prefix: MacroType.protein.abbreviation)
                    macroLabel(value: food.carbsPer100g, color: .macroCarbs, prefix: MacroType.carbs.abbreviation)
                    macroLabel(value: food.fatPer100g, color: .macroFat, prefix: MacroType.fat.abbreviation)
                }
            }
        }
        .padding(.vertical, DS.Spacing.xs)
    }

    @ViewBuilder
    private func macroLabel(value: Double, color: Color, prefix: String) -> some View {
        HStack(spacing: 1) {
            Text(verbatim: prefix).foregroundStyle(color)
            Text(verbatim: value.formatted(.number.precision(.fractionLength(0)))).foregroundStyle(.textTertiary)
        }
        .font(.caption2.weight(.medium))
    }
}

#Preview(traits: .previewContainer()) {
    @Previewable @Environment(AppContainer.self) var container
    @Previewable @State var plan: NutritionPlan? = nil
    Group {
        if let meal = plan?.meals.first {
            MealDetailView(
                meal: meal,
                nutritionRepository: container.nutritionRepository,
                onLogged: {}
            )
        } else {
            ProgressView()
        }
    }
    .task {
        plan = try? await container.nutritionRepository.fetchActivePlan()
    }
}

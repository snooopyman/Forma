//
//  CreateNutritionPlanView.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import SwiftUI

struct CreateNutritionPlanView: View {

    // MARK: - Private Properties

    @State private var viewModel: CreateNutritionPlanViewModel
    @State private var showAddMeal = false
    private let onSaved: () -> Void

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Initializers

    init(nutritionRepository: NutritionRepositoryProtocol, onSaved: @escaping () -> Void) {
        _viewModel = State(initialValue: CreateNutritionPlanViewModel(nutritionRepository: nutritionRepository))
        self.onSaved = onSaved
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Plan")) {
                    TextField(String(localized: "Plan name"), text: $viewModel.planName)
                }

                Section(String(localized: "Daily targets")) {
                    MacroField(label: String(localized: "Calories"), unit: "kcal", text: $viewModel.caloriesText, isDecimal: false)
                    MacroField(label: String(localized: "Protein"), unit: "g", text: $viewModel.proteinText, isDecimal: true)
                    MacroField(label: String(localized: "Carbs"), unit: "g", text: $viewModel.carbsText, isDecimal: true)
                    MacroField(label: String(localized: "Fat"), unit: "g", text: $viewModel.fatText, isDecimal: true)
                }

                Section {
                    ForEach(viewModel.requiredMeals) { meal in
                        DraftMealRow(meal: meal)
                    }
                    ForEach(viewModel.optionalMeals) { meal in
                        DraftMealRow(meal: meal)
                    }
                    .onDelete { viewModel.removeOptionalMeal(at: $0) }

                    Button {
                        showAddMeal = true
                    } label: {
                        Label(String(localized: "Add meal"), systemImage: "plus")
                    }
                } header: {
                    Text(String(localized: "Meals"))
                } footer: {
                    Text(String(localized: "Breakfast, Lunch and Dinner are required"))
                }
            }
            .navigationTitle(String(localized: "New plan"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Save")) {
                        Task {
                            await viewModel.save()
                            if viewModel.errorMessage == nil {
                                onSaved()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showAddMeal) {
                AddMealSheet { draft in
                    viewModel.addMeal(draft)
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
        }
    }
}

// MARK: - MacroField

private struct MacroField: View {

    let label: String
    let unit: String
    @Binding var text: String
    let isDecimal: Bool

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", text: $text)
                .keyboardType(isDecimal ? .decimalPad : .numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(verbatim: unit)
                .foregroundStyle(.textSecondary)
                .frame(width: 36, alignment: .leading)
        }
    }
}

// MARK: - DraftMealRow

private struct DraftMealRow: View {

    let meal: DraftMeal

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(meal.name)
                .font(.body)
            Text(meal.mealType.localizedName)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
    }
}

// MARK: - AddMealSheet

private struct AddMealSheet: View {

    // MARK: - States

    @State private var name = ""
    @State private var mealType = MealType.breakfast

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let onAdd: (DraftMeal) -> Void

    // MARK: - Computed Properties

    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Meal name")) {
                    TextField(String(localized: "e.g. Breakfast"), text: $name)
                }
                Section(String(localized: "Meal type")) {
                    Picker(String(localized: "Meal type"), selection: $mealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.localizedName).tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle(String(localized: "Add meal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Add")) {
                        onAdd(DraftMeal(name: name.trimmingCharacters(in: .whitespaces), mealType: mealType))
                        dismiss()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview(traits: .previewContainer()) {
    @Previewable @Environment(AppContainer.self) var container
    CreateNutritionPlanView(nutritionRepository: container.nutritionRepository, onSaved: {})
}

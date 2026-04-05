//
//  EditNutritionPlanView.swift
//  Forma
//
//  Created by Armando Cáceres on 3/4/26.
//

import SwiftUI

struct EditNutritionPlanView: View {

    // MARK: - Private Properties

    @State private var viewModel: EditNutritionPlanViewModel
    @State private var showAddMeal = false
    private let onSaved: () -> Void

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Initializers

    init(plan: NutritionPlan, nutritionRepository: NutritionRepositoryProtocol, onSaved: @escaping () -> Void) {
        _viewModel = State(initialValue: EditNutritionPlanViewModel(
            plan: plan,
            nutritionRepository: nutritionRepository
        ))
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
                    ForEach(viewModel.meals) { meal in
                        MealRow(meal: meal)
                    }
                    .onDelete { offsets in
                        let toDelete = offsets.map { viewModel.meals[$0] }
                        toDelete.forEach { meal in
                            Task { await viewModel.deleteMeal(meal) }
                        }
                    }

                    Button {
                        showAddMeal = true
                    } label: {
                        Label(String(localized: "Add meal"), systemImage: "plus")
                    }
                } header: {
                    Text(String(localized: "Meals"))
                }
            }
            .navigationTitle(String(localized: "Edit plan"))
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
                AddMealSheet { name, type in
                    Task { await viewModel.addMeal(name: name, type: type) }
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
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .leading)
        }
    }
}

// MARK: - MealRow

private struct MealRow: View {

    let meal: Meal

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(meal.name)
                .font(.body)
            Text(meal.mealType.localizedName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - AddMealSheet

private struct AddMealSheet: View {

    // MARK: - States

    @State private var name = ""
    @State private var mealType = MealType.snack

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let onAdd: (String, MealType) -> Void

    // MARK: - Computed Properties

    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Meal name")) {
                    TextField(String(localized: "e.g. Snack"), text: $name)
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
                        onAdd(name.trimmingCharacters(in: .whitespaces), mealType)
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
    @Previewable @State var plan: NutritionPlan? = nil
    Group {
        if let plan {
            EditNutritionPlanView(
                plan: plan,
                nutritionRepository: container.nutritionRepository,
                onSaved: {}
            )
        } else {
            ProgressView()
        }
    }
    .task {
        plan = try? await container.nutritionRepository.fetchActivePlan()
    }
}

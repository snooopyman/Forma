//
//  PlanOverviewView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct PlanOverviewView: View {

    // MARK: - States

    @AppStorage("postOnboardingAction") private var postOnboardingAction: AppTab = .today
    @State private var viewModel: PlanOverviewViewModel
    @State private var selectedMeal: Meal?
    @State private var showCreatePlan = false
    @State private var showEditPlan = false

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - Initializers

    init(nutritionRepository: NutritionRepositoryProtocol, macroService: MacroTrackingServiceProtocol) {
        _viewModel = State(initialValue: PlanOverviewViewModel(
            nutritionRepository: nutritionRepository,
            macroService: macroService
        ))
    }

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.plan == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.plan == nil {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle(String(localized: "Nutrition"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    FoodBrowserView(repository: container.foodItemRepository)
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
            if viewModel.plan != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditPlan = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .sheet(item: $selectedMeal) { meal in
            MealDetailView(
                meal: meal,
                nutritionRepository: container.nutritionRepository,
                onLogged: { Task { await viewModel.load() } }
            )
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
        .onAppear {
            if postOnboardingAction == .nutrition {
                postOnboardingAction = .today
                showCreatePlan = true
            }
        }
        .refreshable { await viewModel.load() }
        .sheet(isPresented: $showCreatePlan) {
            CreateNutritionPlanView(nutritionRepository: container.nutritionRepository) {
                Task { await viewModel.load() }
            }
        }
        .sheet(isPresented: $showEditPlan) {
            if let plan = viewModel.plan {
                EditNutritionPlanView(
                    plan: plan,
                    nutritionRepository: container.nutritionRepository
                ) {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                if let summary = viewModel.summary {
                    macroHeader(summary: summary)
                }
                mealsSection
            }
            .padding(DS.Spacing.lg)
        }
        .background(.backgroundPrimary)
    }

    @ViewBuilder
    private func macroHeader(summary: DailyMacroSummary) -> some View {
        HStack(spacing: DS.Spacing.xl) {
            MacroRingView(
                proteinCurrent: summary.consumedProteinG,
                proteinGoal: summary.targetProteinG,
                carbsCurrent: summary.consumedCarbsG,
                carbsGoal: summary.targetCarbsG,
                fatCurrent: summary.consumedFatG,
                fatGoal: summary.targetFatG
            )

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                macroRow(
                    label: String(localized: "Calories"),
                    current: summary.consumedCalories,
                    goal: Double(summary.targetCalories),
                    unit: "kcal",
                    color: .accent
                )
                macroRow(
                    label: String(localized: "Protein"),
                    current: summary.consumedProteinG,
                    goal: summary.targetProteinG,
                    unit: "g",
                    color: .macroProtein
                )
                macroRow(
                    label: String(localized: "Carbs"),
                    current: summary.consumedCarbsG,
                    goal: summary.targetCarbsG,
                    unit: "g",
                    color: .macroCarbs
                )
                macroRow(
                    label: String(localized: "Fat"),
                    current: summary.consumedFatG,
                    goal: summary.targetFatG,
                    unit: "g",
                    color: .macroFat
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DS.Spacing.lg)
        .cardStyle()
    }

    @ViewBuilder
    private func macroRow(label: String, current: Double, goal: Double, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)
            HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.xs) {
                Text(verbatim: current.formatted(.number.precision(.fractionLength(0))))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
                Text(verbatim: "/ \(goal.formatted(.number.precision(.fractionLength(0)))) \(unit)")
                    .font(.caption2)
                    .foregroundStyle(.textTertiary)
            }
        }
    }

    @ViewBuilder
    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(String(localized: "Today's meals"))
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .padding(.horizontal, DS.Spacing.xs)

            ForEach(viewModel.sortedMeals) { meal in
                MealRowView(meal: meal, mealLog: viewModel.mealLog(for: meal))
                    .onTapGesture { selectedMeal = meal }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "fork.knife")
                .font(.system(size: 56))
                .foregroundStyle(.textTertiary)
            VStack(spacing: DS.Spacing.sm) {
                Text(String(localized: "No active plan"))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                Text(String(localized: "Create a nutrition plan to start tracking your macros"))
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            Button(String(localized: "Create plan")) {
                showCreatePlan = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(DS.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - MealRowView

private struct MealRowView: View {

    let meal: Meal
    let mealLog: MealLog?

    private var isLogged: Bool { mealLog != nil }

    private var preferredOption: MealOption? {
        meal.options.first { $0.optionNumber == meal.preferredOptionNumber }
            ?? meal.options.sorted { $0.optionNumber < $1.optionNumber }.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            headerRow
            if let option = preferredOption {
                if option.items.isEmpty {
                    Text(String(localized: "No foods added yet"))
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                } else {
                    foodItemsLine(option: option)
                    if option.totalCalories > 0 {
                        macroRow(option: option)
                    }
                }
            } else {
                Text(String(localized: "Tap to add foods"))
                    .font(.caption)
                    .foregroundStyle(.textTertiary)
            }
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }

    @ViewBuilder
    private var headerRow: some View {
        HStack(alignment: .top, spacing: DS.Spacing.md) {
            Image(systemName: isLogged ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isLogged ? Color.success : Color.borderSubtle)

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                Text(meal.mealType.localizedName)
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            if let option = preferredOption, option.totalCalories > 0 {
                Text(verbatim: "\(option.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.textPrimary)
            }
        }
    }

    @ViewBuilder
    private func foodItemsLine(option: MealOption) -> some View {
        let sorted = option.items.sorted { ($0.foodItem?.mainMacro.sortOrder ?? 3) < ($1.foodItem?.mainMacro.sortOrder ?? 3) }
        let visible = sorted.prefix(3)
        let extra = sorted.count - visible.count
        let names = visible.compactMap { item -> String? in
            guard let food = item.foodItem else { return nil }
            return "\(food.name) \(item.amountGrams.formatted(.number.precision(.fractionLength(0))))g"
        }
        let line = (names + (extra > 0 ? ["+\(extra)"] : [])).joined(separator: " · ")
        Text(verbatim: line)
            .font(.caption)
            .foregroundStyle(.textSecondary)
            .lineLimit(2)
    }

    @ViewBuilder
    private func macroRow(option: MealOption) -> some View {
        HStack(spacing: 0) {
            macroStat(
                label: String(localized: "Protein"),
                value: option.totalProteinG,
                color: .macroProtein
            )
            macroStat(
                label: String(localized: "Carbs"),
                value: option.totalCarbsG,
                color: .macroCarbs
            )
            macroStat(
                label: String(localized: "Fat"),
                value: option.totalFatG,
                color: .macroFat
            )
        }
        .padding(.top, DS.Spacing.xs)
    }

    @ViewBuilder
    private func macroStat(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(verbatim: "\(value.formatted(.number.precision(.fractionLength(0))))g")
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview(traits: .previewContainer()) {
    @Previewable @Environment(AppContainer.self) var container
    NavigationStack {
        PlanOverviewView(
            nutritionRepository: container.nutritionRepository,
            macroService: container.macroTrackingService
        )
    }
}

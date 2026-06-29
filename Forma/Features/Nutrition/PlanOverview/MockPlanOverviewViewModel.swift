//
//  MockPlanOverviewViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

@Observable
@MainActor
final class MockPlanOverviewViewModel: PlanOverviewViewModelProtocol {

    // MARK: - States

    var plan: NutritionPlan?
    var todayLog: DailyNutritionLog?
    var summary: DailyMacroSummary?
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var sortedMeals: [Meal] { (plan?.meals ?? []).sorted { $0.order < $1.order } }

    // MARK: - Functions

    func load() async { }
    func mealLog(for meal: Meal) -> MealLog? { nil }
    func logMeal(_ meal: Meal, option: MealOption) async { }
    func unlogMeal(_ meal: Meal) async { }
}

// MARK: - Preview Factories

extension MockPlanOverviewViewModel {
    static var empty: MockPlanOverviewViewModel { MockPlanOverviewViewModel() }

    static var loading: MockPlanOverviewViewModel {
        let vm = MockPlanOverviewViewModel()
        vm.isLoading = true
        return vm
    }

    static var withData: MockPlanOverviewViewModel { MockPlanOverviewViewModel() }

    static var withError: MockPlanOverviewViewModel {
        let vm = MockPlanOverviewViewModel()
        vm.errorMessage = String(localized: "Could not load nutrition data")
        return vm
    }
}

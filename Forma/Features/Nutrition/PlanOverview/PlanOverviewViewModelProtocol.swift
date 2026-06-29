//
//  PlanOverviewViewModelProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import SwiftUI

@MainActor
protocol PlanOverviewViewModelProtocol: AnyObject {
    var plan: NutritionPlan? { get }
    var todayLog: DailyNutritionLog? { get }
    var summary: DailyMacroSummary? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    var sortedMeals: [Meal] { get }
    
    func load() async
    func mealLog(for meal: Meal) -> MealLog?
    func logMeal(_ meal: Meal, option: MealOption) async
    func unlogMeal(_ meal: Meal) async
}

// MARK: - @Entry

extension EnvironmentValues {
    @Entry var planOverviewViewModel: (any PlanOverviewViewModelProtocol)? = nil
}

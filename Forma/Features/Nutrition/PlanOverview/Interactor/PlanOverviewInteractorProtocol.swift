//
//  PlanOverviewInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol PlanOverviewInteractorProtocol: Sendable {
    func fetchActivePlan() async throws -> NutritionPlan?
    func fetchLog(for date: Date) async throws -> DailyNutritionLog?
    func computeSummary(plan: NutritionPlan, log: DailyNutritionLog?) -> DailyMacroSummary
    func saveLog(_ log: DailyNutritionLog) async throws
    func addMealLog(_ mealLog: MealLog, to log: DailyNutritionLog) async throws
    func removeMealLog(_ mealLog: MealLog) async throws
}

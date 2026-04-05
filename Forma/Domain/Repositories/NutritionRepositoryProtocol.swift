//
//  NutritionRepositoryProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation

protocol NutritionRepositoryProtocol: Sendable {
    func fetchAllPlans() async throws -> [NutritionPlan]
    func fetchActivePlan() async throws -> NutritionPlan?

    func savePlan(_ plan: NutritionPlan) async throws
    func deletePlan(_ plan: NutritionPlan) async throws
    func save() async throws

    func setActivePlan(_ plan: NutritionPlan) async throws

    func insertMeal(_ meal: Meal) async throws
    func deleteMeal(_ meal: Meal) async throws

    func insertMealOption(_ option: MealOption) async throws
    func deleteMealOption(_ option: MealOption) async throws

    func insertMealOptionItem(_ item: MealOptionItem) async throws
    func deleteMealOptionItem(_ item: MealOptionItem) async throws

    func fetchLog(for date: Date) async throws -> DailyNutritionLog?
    func saveLog(_ log: DailyNutritionLog) async throws
    func addMealLog(_ mealLog: MealLog, to dailyLog: DailyNutritionLog) async throws
    func removeMealLog(_ mealLog: MealLog) async throws
}

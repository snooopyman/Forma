//
//  MealDetailInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol MealDetailInteractorProtocol: Sendable {
    func fetchLog(for date: Date) async throws -> DailyNutritionLog?
    func saveLog(_ log: DailyNutritionLog) async throws
    func addMealLog(_ mealLog: MealLog, to log: DailyNutritionLog) async throws
    func removeMealLog(_ mealLog: MealLog) async throws
    func save() async throws
    func insertMealOption(_ option: MealOption) async throws
    func deleteMealOption(_ option: MealOption) async throws
    func insertMealOptionItem(_ item: MealOptionItem) async throws
    func deleteMealOptionItem(_ item: MealOptionItem) async throws
}

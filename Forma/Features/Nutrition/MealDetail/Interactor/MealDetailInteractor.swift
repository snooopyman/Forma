//
//  MealDetailInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MealDetailInteractor: MealDetailInteractorProtocol {

    // MARK: - Private Properties

    private let nutritionRepository: NutritionRepositoryProtocol

    // MARK: - Initializers

    init(nutritionRepository: NutritionRepositoryProtocol) {
        self.nutritionRepository = nutritionRepository
    }

    // MARK: - Functions

    func fetchLog(for date: Date) async throws -> DailyNutritionLog? {
        try await nutritionRepository.fetchLog(for: date)
    }

    func saveLog(_ log: DailyNutritionLog) async throws {
        try await nutritionRepository.saveLog(log)
    }

    func addMealLog(_ mealLog: MealLog, to log: DailyNutritionLog) async throws {
        try await nutritionRepository.addMealLog(mealLog, to: log)
    }

    func removeMealLog(_ mealLog: MealLog) async throws {
        try await nutritionRepository.removeMealLog(mealLog)
    }

    func save() async throws {
        try await nutritionRepository.save()
    }

    func insertMealOption(_ option: MealOption) async throws {
        try await nutritionRepository.insertMealOption(option)
    }

    func deleteMealOption(_ option: MealOption) async throws {
        try await nutritionRepository.deleteMealOption(option)
    }

    func insertMealOptionItem(_ item: MealOptionItem) async throws {
        try await nutritionRepository.insertMealOptionItem(item)
    }

    func deleteMealOptionItem(_ item: MealOptionItem) async throws {
        try await nutritionRepository.deleteMealOptionItem(item)
    }
}

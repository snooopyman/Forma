//
//  EditPlanInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class EditPlanInteractor: EditPlanInteractorProtocol {

    // MARK: - Private Properties

    private let nutritionRepository: NutritionRepositoryProtocol

    // MARK: - Initializers

    init(nutritionRepository: NutritionRepositoryProtocol) {
        self.nutritionRepository = nutritionRepository
    }

    // MARK: - Functions

    func save() async throws {
        try await nutritionRepository.save()
    }

    func insertMeal(_ meal: Meal) async throws {
        try await nutritionRepository.insertMeal(meal)
    }

    func deleteMeal(_ meal: Meal) async throws {
        try await nutritionRepository.deleteMeal(meal)
    }
}

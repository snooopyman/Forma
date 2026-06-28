//
//  CreatePlanInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class CreatePlanInteractor: CreatePlanInteractorProtocol {

    // MARK: - Private Properties

    private let nutritionRepository: NutritionRepositoryProtocol

    // MARK: - Initializers

    init(nutritionRepository: NutritionRepositoryProtocol) {
        self.nutritionRepository = nutritionRepository
    }

    // MARK: - Functions

    func savePlan(_ plan: NutritionPlan) async throws {
        try await nutritionRepository.savePlan(plan)
    }

    func setActivePlan(_ plan: NutritionPlan) async throws {
        try await nutritionRepository.setActivePlan(plan)
    }
}

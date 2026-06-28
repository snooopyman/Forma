//
//  PlanOverviewInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class PlanOverviewInteractor: PlanOverviewInteractorProtocol {

    // MARK: - Private Properties

    private let nutritionRepository: NutritionRepositoryProtocol
    private let macroService: MacroTrackingServiceProtocol

    // MARK: - Initializers

    init(
        nutritionRepository: NutritionRepositoryProtocol,
        macroService: MacroTrackingServiceProtocol
    ) {
        self.nutritionRepository = nutritionRepository
        self.macroService = macroService
    }

    // MARK: - Functions

    func fetchActivePlan() async throws -> NutritionPlan? {
        try await nutritionRepository.fetchActivePlan()
    }

    func fetchLog(for date: Date) async throws -> DailyNutritionLog? {
        try await nutritionRepository.fetchLog(for: date)
    }

    func computeSummary(plan: NutritionPlan, log: DailyNutritionLog?) -> DailyMacroSummary {
        macroService.computeDailySummary(plan: plan, log: log)
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
}

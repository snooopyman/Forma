//
//  PlanOverviewViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class PlanOverviewViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let nutritionRepository: NutritionRepositoryProtocol
    @ObservationIgnored
    private let macroService: MacroTrackingServiceProtocol

    // MARK: - States

    var plan: NutritionPlan?
    var todayLog: DailyNutritionLog?
    var summary: DailyMacroSummary?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var sortedMeals: [Meal] {
        (plan?.meals ?? []).sorted { $0.order < $1.order }
    }

    // MARK: - Initializers

    init(nutritionRepository: NutritionRepositoryProtocol, macroService: MacroTrackingServiceProtocol) {
        self.nutritionRepository = nutritionRepository
        self.macroService = macroService
    }

    // MARK: - Functions

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            plan = try await nutritionRepository.fetchActivePlan()
            todayLog = try await nutritionRepository.fetchLog(for: .now)
            recomputeSummary()
        } catch {
            Logger.nutrition.error("Failed to load nutrition plan: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func mealLog(for meal: Meal) -> MealLog? {
        todayLog?.mealLogs.first { $0.meal?.id == meal.id && $0.wasFollowed }
    }

    func logMeal(_ meal: Meal, option: MealOption) async {
        do {
            let log = try await ensureTodayLog()
            if let existing = todayLog?.mealLogs.first(where: { $0.meal?.id == meal.id }) {
                try await nutritionRepository.removeMealLog(existing)
            }
            let mealLog = MealLog(wasFollowed: true)
            mealLog.meal = meal
            mealLog.selectedOption = option
            try await nutritionRepository.addMealLog(mealLog, to: log)
            todayLog = try await nutritionRepository.fetchLog(for: .now)
            recomputeSummary()
            Logger.nutrition.info("Logged meal: \(meal.name, privacy: .public)")
        } catch {
            Logger.nutrition.error("Failed to log meal: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func unlogMeal(_ meal: Meal) async {
        guard let existing = todayLog?.mealLogs.first(where: { $0.meal?.id == meal.id }) else { return }
        do {
            try await nutritionRepository.removeMealLog(existing)
            todayLog = try await nutritionRepository.fetchLog(for: .now)
            recomputeSummary()
        } catch {
            Logger.nutrition.error("Failed to unlog meal: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    // MARK: - Private Functions

    private func recomputeSummary() {
        guard let plan else { summary = nil; return }
        summary = macroService.computeDailySummary(plan: plan, log: todayLog)
    }

    private func ensureTodayLog() async throws -> DailyNutritionLog {
        if let existing = todayLog { return existing }
        let newLog = DailyNutritionLog(date: .now)
        try await nutritionRepository.saveLog(newLog)
        todayLog = newLog
        return newLog
    }
}

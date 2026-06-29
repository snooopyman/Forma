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
final class PlanOverviewViewModel: PlanOverviewViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: PlanOverviewInteractorProtocol

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

    init(interactor: PlanOverviewInteractorProtocol) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            plan = try await interactor.fetchActivePlan()
            todayLog = try await interactor.fetchLog(for: .now)
            recomputeSummary()
        } catch {
            handleError(error)
        }
    }

    func mealLog(for meal: Meal) -> MealLog? {
        todayLog?.mealLogs.first { $0.meal?.id == meal.id && $0.wasFollowed }
    }

    func logMeal(_ meal: Meal, option: MealOption) async {
        do {
            let log = try await ensureTodayLog()
            if let existing = todayLog?.mealLogs.first(where: { $0.meal?.id == meal.id }) {
                try await interactor.removeMealLog(existing)
            }
            let mealLog = MealLog(wasFollowed: true)
            mealLog.meal = meal
            mealLog.selectedOption = option
            try await interactor.addMealLog(mealLog, to: log)
            todayLog = try await interactor.fetchLog(for: .now)
            recomputeSummary()
            Logger.nutrition.info("Logged meal: \(meal.name, privacy: .public)")
        } catch {
            handleError(error)
        }
    }

    func unlogMeal(_ meal: Meal) async {
        guard let existing = todayLog?.mealLogs.first(where: { $0.meal?.id == meal.id }) else { return }
        do {
            try await interactor.removeMealLog(existing)
            todayLog = try await interactor.fetchLog(for: .now)
            recomputeSummary()
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        Logger.nutrition.error("Error: \(error, privacy: .private)")
        if let nutritionError = error as? NutritionError {
            errorMessage = nutritionError.errorDescription
        } else {
            errorMessage = String(localized: "Something went wrong")
        }
    }

    private func recomputeSummary() {
        guard let plan else { summary = nil; return }
        summary = interactor.computeSummary(plan: plan, log: todayLog)
    }

    private func ensureTodayLog() async throws -> DailyNutritionLog {
        if let existing = todayLog { return existing }
        let newLog = DailyNutritionLog(date: .now)
        try await interactor.saveLog(newLog)
        todayLog = newLog
        return newLog
    }
}

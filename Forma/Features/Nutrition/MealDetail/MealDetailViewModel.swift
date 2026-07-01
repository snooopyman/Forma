//
//  MealDetailViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class MealDetailViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: MealDetailInteractorProtocol
    
    // MARK: - States
    
    var selectedOptionIndex: Int = 0
    var todayLog: DailyNutritionLog?
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Properties
    
    let meal: Meal
    
    // MARK: - Computed Properties
    
    var sortedOptions: [MealOption] {
        meal.options.sorted { $0.optionNumber < $1.optionNumber }
    }
    
    var selectedOption: MealOption? {
        guard selectedOptionIndex < sortedOptions.count else { return nil }
        return sortedOptions[selectedOptionIndex]
    }
    
    var loggedOption: MealOption? {
        todayLog?.mealLogs.first { $0.meal?.id == meal.id && $0.wasFollowed }?.selectedOption
    }
    
    var isLogged: Bool { loggedOption != nil }
    
    var isSelectedOptionPreferred: Bool {
        selectedOption?.optionNumber == meal.preferredOptionNumber
    }
    
    // MARK: - Initializers
    
    init(meal: Meal, interactor: MealDetailInteractorProtocol) {
        self.meal = meal
        self.interactor = interactor
    }
    
    // MARK: - Functions
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            todayLog = try await interactor.fetchLog(for: .now)
            if let logged = loggedOption,
               let idx = sortedOptions.firstIndex(where: { $0.id == logged.id }) {
                selectedOptionIndex = idx
            } else if let idx = sortedOptions.firstIndex(where: { $0.optionNumber == meal.preferredOptionNumber }) {
                selectedOptionIndex = idx
            }
        } catch {
            handleError(error)
        }
    }
    
    func logSelectedOption() async {
        guard let option = selectedOption else { return }
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
            Logger.nutrition.info("Logged option \(option.optionNumber, privacy: .public) for \(self.meal.name, privacy: .public)")
        } catch {
            handleError(error)
        }
    }
    
    func unlog() async {
        guard let existing = todayLog?.mealLogs.first(where: { $0.meal?.id == meal.id }) else { return }
        do {
            try await interactor.removeMealLog(existing)
            todayLog = try await interactor.fetchLog(for: .now)
        } catch {
            handleError(error)
        }
    }
    
    func setPreferredOption() async {
        guard let option = selectedOption else { return }
        meal.preferredOptionNumber = option.optionNumber
        do {
            try await interactor.save()
            Logger.nutrition.info("Set preferred option \(option.optionNumber, privacy: .public) for \(self.meal.name, privacy: .public)")
        } catch {
            handleError(error)
        }
    }
    
    func addOption() async {
        let nextNumber = (meal.options.map { $0.optionNumber }.max() ?? 0) + 1
        guard nextNumber <= 3 else { return }
        let option = MealOption(optionNumber: nextNumber)
        option.meal = meal
        meal.options.append(option)
        do {
            try await interactor.insertMealOption(option)
            if let idx = sortedOptions.firstIndex(where: { $0.id == option.id }) {
                selectedOptionIndex = idx
            }
            Logger.nutrition.info("Added option \(nextNumber, privacy: .public) to meal \(self.meal.name, privacy: .public)")
        } catch {
            handleError(error)
        }
    }
    
    func deleteOption(_ option: MealOption) async {
        do {
            try await interactor.deleteMealOption(option)
            selectedOptionIndex = 0
            Logger.nutrition.info("Deleted option from meal \(self.meal.name, privacy: .public)")
        } catch {
            handleError(error)
        }
    }
    
    func addFoodItem(_ food: FoodItem, grams: Double, to option: MealOption) async {
        let item = MealOptionItem(amountGrams: grams)
        item.foodItem = food
        item.mealOption = option
        option.items.append(item)
        do {
            try await interactor.insertMealOptionItem(item)
            Logger.nutrition.info("Added \(food.name, privacy: .public) (\(grams, privacy: .public)g) to option")
        } catch {
            handleError(error)
        }
    }
    
    func deleteFoodItem(_ item: MealOptionItem) async {
        do {
            try await interactor.deleteMealOptionItem(item)
            Logger.nutrition.info("Deleted food item from option")
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
            errorMessage = L10n.Error.generic
        }
    }
    
    private func ensureTodayLog() async throws -> DailyNutritionLog {
        if let existing = todayLog { return existing }
        let newLog = DailyNutritionLog(date: .now)
        try await interactor.saveLog(newLog)
        todayLog = newLog
        return newLog
    }
}

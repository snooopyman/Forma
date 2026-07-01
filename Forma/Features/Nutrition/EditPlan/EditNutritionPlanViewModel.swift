//
//  EditNutritionPlanViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 3/4/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class EditNutritionPlanViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: EditPlanInteractorProtocol
    
    // MARK: - States
    
    var planName: String
    var caloriesText: String
    var proteinText: String
    var carbsText: String
    var fatText: String
    var meals: [Meal] = []
    var isSaving = false
    var errorMessage: String?
    
    // MARK: - Properties
    
    let plan: NutritionPlan
    
    // MARK: - Computed Properties
    
    var isValid: Bool {
        !planName.trimmingCharacters(in: .whitespaces).isEmpty
        && Int(caloriesText) != nil
        && Double(normalized(proteinText)) != nil
        && Double(normalized(carbsText)) != nil
        && Double(normalized(fatText)) != nil
    }
    
    // MARK: - Initializers
    
    init(plan: NutritionPlan, interactor: EditPlanInteractorProtocol) {
        self.plan = plan
        self.interactor = interactor
        self.planName = plan.name
        self.caloriesText = String(plan.targetCalories)
        self.proteinText = plan.targetProteinG.formatted(.number.precision(.fractionLength(1)))
        self.carbsText = plan.targetCarbsG.formatted(.number.precision(.fractionLength(1)))
        self.fatText = plan.targetFatG.formatted(.number.precision(.fractionLength(1)))
        self.meals = plan.meals.sorted { $0.order < $1.order }
    }
    
    // MARK: - Functions
    
    func addMeal(name: String, type: MealType) async {
        let order = (plan.meals.map { $0.order }.max() ?? -1) + 1
        let meal = Meal(name: name, mealType: type, order: order)
        meal.nutritionPlan = plan
        plan.meals.append(meal)
        do {
            try await interactor.insertMeal(meal)
            meals = plan.meals.sorted { $0.order < $1.order }
            Logger.nutrition.info("Added meal: \(meal.name, privacy: .public)")
        } catch {
            handleError(error)
        }
    }
    
    func deleteMeal(_ meal: Meal) async {
        do {
            try await interactor.deleteMeal(meal)
            meals = plan.meals.sorted { $0.order < $1.order }
            Logger.nutrition.info("Deleted meal: \(meal.name, privacy: .public)")
        } catch {
            handleError(error)
        }
    }
    
    func save() async {
        guard isValid,
              let calories = Int(caloriesText),
              let protein = Double(normalized(proteinText)),
              let carbs = Double(normalized(carbsText)),
              let fat = Double(normalized(fatText)) else { return }
        isSaving = true
        defer { isSaving = false }
        plan.name = planName.trimmingCharacters(in: .whitespaces)
        plan.targetCalories = calories
        plan.targetProteinG = protein
        plan.targetCarbsG = carbs
        plan.targetFatG = fat
        do {
            try await interactor.save()
            Logger.nutrition.info("Updated plan: \(self.plan.name, privacy: .public)")
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
    
    private func normalized(_ text: String) -> String {
        text.replacingOccurrences(of: ",", with: ".")
    }
}

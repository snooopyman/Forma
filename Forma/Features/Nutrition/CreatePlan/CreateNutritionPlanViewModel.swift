//
//  CreateNutritionPlanViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import Foundation
import OSLog
import SwiftUI

struct DraftMeal: Identifiable {
    let id = UUID()
    var name: String
    var mealType: MealType
    var isRequired: Bool = false
}

@Observable
@MainActor
final class CreateNutritionPlanViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: CreatePlanInteractorProtocol
    
    // MARK: - States
    
    var planName = ""
    var caloriesText = ""
    var proteinText = ""
    var carbsText = ""
    var fatText = ""
    var draftMeals: [DraftMeal] = []
    var isSaving = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var isValid: Bool {
        !planName.trimmingCharacters(in: .whitespaces).isEmpty
        && Int(caloriesText) != nil
        && Double(proteinText) != nil
        && Double(carbsText) != nil
        && Double(fatText) != nil
    }
    
    var requiredMeals: [DraftMeal] { draftMeals.filter { $0.isRequired } }
    var optionalMeals: [DraftMeal] { draftMeals.filter { !$0.isRequired } }
    
    // MARK: - Initializers
    
    init(interactor: CreatePlanInteractorProtocol) {
        self.interactor = interactor
        draftMeals = [
            DraftMeal(name: L10n.Nutrition.Meal.breakfast, mealType: .breakfast, isRequired: true),
            DraftMeal(name: L10n.Nutrition.Meal.lunch, mealType: .lunch, isRequired: true),
            DraftMeal(name: L10n.Nutrition.Meal.dinner, mealType: .dinner, isRequired: true),
        ]
    }
    
    // MARK: - Functions
    
    func addMeal(_ draft: DraftMeal) {
        draftMeals.append(draft)
    }
    
    func removeOptionalMeal(at offsets: IndexSet) {
        let optionalIndices = draftMeals.indices.filter { !draftMeals[$0].isRequired }
        let toRemove = IndexSet(offsets.map { optionalIndices[$0] })
        draftMeals.remove(atOffsets: toRemove)
    }
    
    func save() async {
        guard let calories = Int(caloriesText),
              let protein = Double(proteinText),
              let carbs = Double(carbsText),
              let fat = Double(fatText) else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            let plan = NutritionPlan(
                name: planName.trimmingCharacters(in: .whitespaces),
                targetCalories: calories,
                targetProteinG: protein,
                targetCarbsG: carbs,
                targetFatG: fat
            )
            for (idx, draft) in draftMeals.enumerated() {
                let meal = Meal(name: draft.name, mealType: draft.mealType, order: idx)
                meal.nutritionPlan = plan
                plan.meals.append(meal)
            }
            try await interactor.savePlan(plan)
            try await interactor.setActivePlan(plan)
            Logger.nutrition.info("Created plan: \(plan.name, privacy: .public)")
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
}

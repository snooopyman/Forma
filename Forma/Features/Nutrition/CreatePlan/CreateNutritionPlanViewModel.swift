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
    private let nutritionRepository: NutritionRepositoryProtocol

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

    init(nutritionRepository: NutritionRepositoryProtocol) {
        self.nutritionRepository = nutritionRepository
        draftMeals = [
            DraftMeal(name: String(localized: "Breakfast"), mealType: .breakfast, isRequired: true),
            DraftMeal(name: String(localized: "Lunch"), mealType: .lunch, isRequired: true),
            DraftMeal(name: String(localized: "Dinner"), mealType: .dinner, isRequired: true),
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
            try await nutritionRepository.savePlan(plan)
            try await nutritionRepository.setActivePlan(plan)
            Logger.nutrition.info("Created plan: \(plan.name, privacy: .public)")
        } catch {
            Logger.nutrition.error("Failed to create plan: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }
}

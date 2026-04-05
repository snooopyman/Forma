//
//  MacroTrackingService.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import Foundation

struct DailyMacroSummary: Sendable {
    let consumedCalories: Double
    let consumedProteinG: Double
    let consumedCarbsG: Double
    let consumedFatG: Double
    let targetCalories: Int
    let targetProteinG: Double
    let targetCarbsG: Double
    let targetFatG: Double

    var remainingCalories: Double { Double(targetCalories) - consumedCalories }
    var remainingProteinG: Double { targetProteinG - consumedProteinG }
    var remainingCarbsG:   Double { targetCarbsG - consumedCarbsG }
    var remainingFatG:     Double { targetFatG - consumedFatG }
}

protocol MacroTrackingServiceProtocol: Sendable {
    func computeDailySummary(plan: NutritionPlan, log: DailyNutritionLog?) -> DailyMacroSummary
}

struct MacroTrackingService: MacroTrackingServiceProtocol {

    func computeDailySummary(plan: NutritionPlan, log: DailyNutritionLog?) -> DailyMacroSummary {
        var calories = 0.0
        var protein  = 0.0
        var carbs    = 0.0
        var fat      = 0.0

        if let log {
            for mealLog in log.mealLogs where mealLog.wasFollowed {
                if let option = mealLog.selectedOption {
                    calories += option.totalCalories
                    protein  += option.totalProteinG
                    carbs    += option.totalCarbsG
                    fat      += option.totalFatG
                }
            }
        }

        return DailyMacroSummary(
            consumedCalories: calories,
            consumedProteinG: protein,
            consumedCarbsG:   carbs,
            consumedFatG:     fat,
            targetCalories:   plan.targetCalories,
            targetProteinG:   plan.targetProteinG,
            targetCarbsG:     plan.targetCarbsG,
            targetFatG:       plan.targetFatG
        )
    }
}

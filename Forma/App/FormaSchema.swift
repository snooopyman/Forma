//
//  FormaSchema.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftData

enum FormaSchema {
    static let models: [any PersistentModel.Type] = [
        UserProfile.self,
        Mesocycle.self,
        WorkoutDay.self,
        Exercise.self,
        PlannedExercise.self,
        WorkoutSession.self,
        LoggedSet.self,
        MuscleVolumeTarget.self,
        BodyMeasurement.self,
        ProgressPhoto.self,
        NutritionPlan.self,
        Meal.self,
        MealOption.self,
        MealOptionItem.self,
        FoodItem.self,
        DailyNutritionLog.self,
        MealLog.self,
    ]
}

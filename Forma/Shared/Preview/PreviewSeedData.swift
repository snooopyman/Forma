//
//  PreviewSeedData.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

enum PreviewSeedData {

    static func insert(into context: ModelContext) {
        insertUserProfile(into: context)
        let exercises = insertExercises(into: context)
        insertMesocycle(with: exercises, into: context)
        let foodItems = insertFoodItems(into: context)
        insertNutritionPlan(with: foodItems, into: context)
        insertBodyMeasurements(into: context)
    }

    // MARK: - User Profile

    private static func insertUserProfile(into context: ModelContext) {
        let profile = UserProfile(
            name: "Armando",
            birthDate: Calendar.current.date(from: DateComponents(year: 1990, month: 6, day: 15))!,
            heightCm: 178,
            biologicalSex: .male,
            activityLevel: .moderatelyActive,
            weightUnit: .kg
        )
        context.insert(profile)
    }

    // MARK: - Exercises

    private static func insertExercises(into context: ModelContext) -> [Exercise] {
        let exercises: [Exercise] = [
            Exercise(name: "Bench Press", primaryMuscle: .chest, secondaryMuscles: [.triceps, .shoulders], equipment: "Barbell"),
            Exercise(name: "Incline Dumbbell Press", primaryMuscle: .chest, secondaryMuscles: [.shoulders], equipment: "Dumbbell"),
            Exercise(name: "Pull-Up", primaryMuscle: .back, secondaryMuscles: [.biceps, .shoulders], equipment: "Bodyweight"),
            Exercise(name: "Barbell Row", primaryMuscle: .back, secondaryMuscles: [.biceps, .shoulders], equipment: "Barbell"),
            Exercise(name: "Squat", primaryMuscle: .quadriceps, secondaryMuscles: [.glutes, .hamstrings], equipment: "Barbell"),
            Exercise(name: "Romanian Deadlift", primaryMuscle: .hamstrings, secondaryMuscles: [.glutes, .back], equipment: "Barbell"),
            Exercise(name: "Overhead Press", primaryMuscle: .shoulders, secondaryMuscles: [.triceps], equipment: "Barbell"),
            Exercise(name: "Lateral Raise", primaryMuscle: .shoulders, equipment: "Dumbbell"),
            Exercise(name: "Tricep Pushdown", primaryMuscle: .triceps, equipment: "Cable"),
            Exercise(name: "Barbell Curl", primaryMuscle: .biceps, equipment: "Barbell"),
        ]
        exercises.forEach { context.insert($0) }
        return exercises
    }

    // MARK: - Mesocycle

    private static func insertMesocycle(with exercises: [Exercise], into context: ModelContext) {
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: .now)!
        let mesocycle = Mesocycle(
            name: "Hipertrofia Bloque 1",
            startDate: startDate,
            durationWeeks: 6,
            useFixedDays: true,
            isActive: true
        )
        context.insert(mesocycle)

        let chestExercise = exercises[0]
        let inclineExercise = exercises[1]
        let pullUpExercise = exercises[2]
        let rowExercise = exercises[3]
        let squatExercise = exercises[4]
        let rdlExercise = exercises[5]
        let ohpExercise = exercises[6]
        let lateralExercise = exercises[7]
        let tricepExercise = exercises[8]
        let curlExercise = exercises[9]

        // Day 1 — Push (chest / front delts / triceps)
        let push = WorkoutDay(name: "Push", order: 0, weekday: .monday)
        context.insert(push)
        push.mesocycle = mesocycle

        let pe1 = makePlannedExercise(order: 0, sets: 4, exercise: chestExercise)
        let pe2 = makePlannedExercise(order: 1, sets: 3, exercise: inclineExercise)
        let pe3 = makePlannedExercise(order: 2, sets: 3, exercise: ohpExercise)
        let pe4 = makePlannedExercise(order: 3, sets: 3, exercise: lateralExercise)
        let pe5 = makePlannedExercise(order: 4, sets: 3, exercise: tricepExercise)
        [pe1, pe2, pe3, pe4, pe5].forEach {
            context.insert($0)
            $0.workoutDay = push
        }

        // Day 2 — Pull (lats / rear delts / biceps)
        let pull = WorkoutDay(name: "Pull", order: 1, weekday: .wednesday)
        context.insert(pull)
        pull.mesocycle = mesocycle

        let pe6 = makePlannedExercise(order: 0, sets: 4, exercise: pullUpExercise)
        let pe7 = makePlannedExercise(order: 1, sets: 4, exercise: rowExercise)
        let pe8 = makePlannedExercise(order: 2, sets: 3, exercise: curlExercise)
        [pe6, pe7, pe8].forEach {
            context.insert($0)
            $0.workoutDay = pull
        }

        // Day 3 — Legs (quads / hamstrings / glutes)
        let legs = WorkoutDay(name: "Legs", order: 2, weekday: .friday)
        context.insert(legs)
        legs.mesocycle = mesocycle

        let pe9 = makePlannedExercise(order: 0, sets: 4, exercise: squatExercise, rirTarget: 3)
        let pe10 = makePlannedExercise(order: 1, sets: 3, exercise: rdlExercise)
        [pe9, pe10].forEach {
            context.insert($0)
            $0.workoutDay = legs
        }

        // Day 4 — Rest
        let rest = WorkoutDay(name: "Rest", order: 3, weekday: .sunday, isRestDay: true)
        context.insert(rest)
        rest.mesocycle = mesocycle

        mesocycle.workoutDays = [push, pull, legs, rest]
    }

    private static func makePlannedExercise(
        order: Int,
        sets: Int = 3,
        exercise: Exercise,
        repsMin: Int = 8,
        repsMax: Int = 12,
        rirTarget: Int = 2,
        restSeconds: Int = 120
    ) -> PlannedExercise {
        let pe = PlannedExercise(
            order: order,
            sets: sets,
            repsMin: repsMin,
            repsMax: repsMax,
            rirTarget: rirTarget,
            restSeconds: restSeconds,
            cadence: "2-0-1"
        )
        pe.exercise = exercise
        return pe
    }

    // MARK: - Food Items

    private static func insertFoodItems(into context: ModelContext) -> [FoodItem] {
        let items: [FoodItem] = [
            FoodItem(name: "Chicken Breast", category: "Meat", mainMacro: .protein, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, basePortionG: 150),
            FoodItem(name: "White Rice", category: "Grains", mainMacro: .carbs, caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28, fatPer100g: 0.3, fiberPer100g: 0.4, basePortionG: 200),
            FoodItem(name: "Whole Eggs", category: "Dairy & Eggs", mainMacro: .protein, caloriesPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatPer100g: 11, basePortionG: 120),
            FoodItem(name: "Oats", category: "Grains", mainMacro: .carbs, caloriesPer100g: 389, proteinPer100g: 17, carbsPer100g: 66, fatPer100g: 7, fiberPer100g: 11, basePortionG: 80),
            FoodItem(name: "Greek Yogurt", category: "Dairy & Eggs", mainMacro: .protein, caloriesPer100g: 97, proteinPer100g: 10, carbsPer100g: 4, fatPer100g: 5, basePortionG: 200),
            FoodItem(name: "Banana", category: "Fruit", mainMacro: .carbs, caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23, fatPer100g: 0.3, fiberPer100g: 2.6, basePortionG: 120),
            FoodItem(name: "Salmon", category: "Fish", mainMacro: .protein, caloriesPer100g: 208, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 13, basePortionG: 150),
            FoodItem(name: "Avocado", category: "Fruit", mainMacro: .fat, caloriesPer100g: 160, proteinPer100g: 2, carbsPer100g: 9, fatPer100g: 15, fiberPer100g: 7, basePortionG: 80),
            FoodItem(name: "Whey Protein", category: "Supplements", mainMacro: .protein, caloriesPer100g: 380, proteinPer100g: 80, carbsPer100g: 8, fatPer100g: 4, basePortionG: 30),
            FoodItem(name: "Sweet Potato", category: "Vegetables", mainMacro: .carbs, caloriesPer100g: 86, proteinPer100g: 1.6, carbsPer100g: 20, fatPer100g: 0.1, fiberPer100g: 3, basePortionG: 200),
        ]
        items.forEach { context.insert($0) }
        return items
    }

    // MARK: - Nutrition Plan

    private static func insertNutritionPlan(with foodItems: [FoodItem], into context: ModelContext) {
        let plan = NutritionPlan(
            name: "Bulk limpio",
            isActive: true,
            targetCalories: 2800,
            targetProteinG: 180,
            targetCarbsG: 320,
            targetFatG: 75
        )
        context.insert(plan)

        let chicken = foodItems[0]
        let rice = foodItems[1]
        let eggs = foodItems[2]
        let oats = foodItems[3]
        let yogurt = foodItems[4]
        let banana = foodItems[5]
        let whey = foodItems[8]
        let sweetPotato = foodItems[9]

        // Breakfast
        let breakfast = Meal(name: "Breakfast", mealType: .breakfast, order: 0, targetCalories: 600, targetProteinG: 40, targetCarbsG: 70, targetFatG: 15)
        context.insert(breakfast)
        breakfast.nutritionPlan = plan

        let bfOption = MealOption(optionNumber: 1)
        context.insert(bfOption)
        bfOption.meal = breakfast
        let bfItem1 = makeItem(food: oats, grams: 80)
        let bfItem2 = makeItem(food: yogurt, grams: 200)
        let bfItem3 = makeItem(food: banana, grams: 120)
        [bfItem1, bfItem2, bfItem3].forEach {
            context.insert($0)
            $0.mealOption = bfOption
        }

        // Lunch
        let lunch = Meal(name: "Lunch", mealType: .lunch, order: 1, targetCalories: 800, targetProteinG: 60, targetCarbsG: 90, targetFatG: 15)
        context.insert(lunch)
        lunch.nutritionPlan = plan

        let lOption = MealOption(optionNumber: 1)
        context.insert(lOption)
        lOption.meal = lunch
        let lItem1 = makeItem(food: chicken, grams: 200)
        let lItem2 = makeItem(food: rice, grams: 200)
        [lItem1, lItem2].forEach {
            context.insert($0)
            $0.mealOption = lOption
        }

        // Post-workout
        let postWorkout = Meal(name: "Post-workout", mealType: .postWorkout, order: 2, targetCalories: 400, targetProteinG: 35, targetCarbsG: 50, targetFatG: 5)
        context.insert(postWorkout)
        postWorkout.nutritionPlan = plan

        let pwOption = MealOption(optionNumber: 1)
        context.insert(pwOption)
        pwOption.meal = postWorkout
        let pwItem1 = makeItem(food: whey, grams: 30)
        let pwItem2 = makeItem(food: sweetPotato, grams: 200)
        [pwItem1, pwItem2].forEach {
            context.insert($0)
            $0.mealOption = pwOption
        }

        // Dinner
        let dinner = Meal(name: "Dinner", mealType: .dinner, order: 3, targetCalories: 700, targetProteinG: 45, targetCarbsG: 60, targetFatG: 20)
        context.insert(dinner)
        dinner.nutritionPlan = plan

        let dOption = MealOption(optionNumber: 1)
        context.insert(dOption)
        dOption.meal = dinner
        let dItem1 = makeItem(food: eggs, grams: 180)
        let dItem2 = makeItem(food: sweetPotato, grams: 150)
        [dItem1, dItem2].forEach {
            context.insert($0)
            $0.mealOption = dOption
        }

        plan.meals = [breakfast, lunch, postWorkout, dinner]
    }

    private static func makeItem(food: FoodItem, grams: Double) -> MealOptionItem {
        let item = MealOptionItem(amountGrams: grams)
        item.foodItem = food
        return item
    }

    // MARK: - Body Measurements

    private static func insertBodyMeasurements(into context: ModelContext) {
        let entries: [(daysAgo: Int, kg: Double, waist: Double, abdomen: Double, neck: Double)] = [
            (42, 79.2, 82.0, 88.0, 38.0),
            (35, 79.8, 81.8, 87.5, 38.0),
            (28, 80.1, 81.5, 87.0, 38.2),
            (21, 80.5, 81.2, 86.5, 38.2),
            (14, 81.0, 80.8, 86.0, 38.4),
            (7,  81.4, 80.5, 85.5, 38.4),
            (0,  81.8, 80.0, 85.0, 38.5),
        ]
        for entry in entries {
            let date = Calendar.current.date(byAdding: .day, value: -entry.daysAgo, to: .now)!
            let measurement = BodyMeasurement(
                date: date,
                weightKg: entry.kg,
                heightCm: 178,
                biologicalSex: .male,
                neckCm: entry.neck,
                armCm: 36.0,
                waistCm: entry.waist,
                abdomenCm: entry.abdomen
            )
            context.insert(measurement)
        }
    }
}

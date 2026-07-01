//
//  MockPlanOverviewViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

@Observable
@MainActor
final class MockPlanOverviewViewModel: PlanOverviewViewModelProtocol {

    // MARK: - States

    var plan: NutritionPlan?
    var todayLog: DailyNutritionLog?
    var summary: DailyMacroSummary?
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var sortedMeals: [Meal] { (plan?.meals ?? []).sorted { $0.order < $1.order } }

    // MARK: - Functions

    func load() async { }
    func mealLog(for meal: Meal) -> MealLog? {
        todayLog?.mealLogs.first { $0.meal?.id == meal.id }
    }
    func logMeal(_ meal: Meal, option: MealOption) async { }
    func unlogMeal(_ meal: Meal) async { }
}

// MARK: - Preview Factories

extension MockPlanOverviewViewModel {
    static var empty: MockPlanOverviewViewModel { MockPlanOverviewViewModel() }

    static var loading: MockPlanOverviewViewModel {
        let vm = MockPlanOverviewViewModel()
        vm.isLoading = true
        return vm
    }

    static var withData: MockPlanOverviewViewModel {
        let vm = MockPlanOverviewViewModel()

        let plan = NutritionPlan(
            name: "Bulk limpio",
            isActive: true,
            targetCalories: 2800,
            targetProteinG: 180,
            targetCarbsG: 320,
            targetFatG: 75
        )

        let chicken = FoodItem(name: "Chicken Breast", category: "Meat", mainMacro: .protein, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6)
        let rice = FoodItem(name: "White Rice (cooked)", category: "Grains", mainMacro: .carbs, caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28, fatPer100g: 0.3)
        let oats = FoodItem(name: "Oats (dry)", category: "Grains", mainMacro: .carbs, caloriesPer100g: 389, proteinPer100g: 17, carbsPer100g: 66, fatPer100g: 7)
        let yogurt = FoodItem(name: "Greek Yogurt 0%", category: "Dairy", mainMacro: .protein, caloriesPer100g: 59, proteinPer100g: 10, carbsPer100g: 3.6, fatPer100g: 0.4)
        let banana = FoodItem(name: "Banana", category: "Fruit", mainMacro: .carbs, caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23, fatPer100g: 0.3)
        let eggs = FoodItem(name: "Whole Eggs", category: "Dairy", mainMacro: .protein, caloriesPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatPer100g: 11)
        let sweetPotato = FoodItem(name: "Sweet Potato", category: "Grains", mainMacro: .carbs, caloriesPer100g: 86, proteinPer100g: 1.6, carbsPer100g: 20, fatPer100g: 0.1)

        let breakfast = Meal(name: "Breakfast", mealType: .breakfast, order: 0, targetCalories: 600, targetProteinG: 40, targetCarbsG: 70, targetFatG: 15)
        breakfast.nutritionPlan = plan
        let bfOption = MealOption(optionNumber: 1)
        bfOption.meal = breakfast
        bfOption.items = [
            makeItem(food: oats, grams: 80),
            makeItem(food: yogurt, grams: 200),
            makeItem(food: banana, grams: 120)
        ]
        breakfast.options = [bfOption]

        let lunch = Meal(name: "Lunch", mealType: .lunch, order: 1, targetCalories: 800, targetProteinG: 60, targetCarbsG: 90, targetFatG: 15)
        lunch.nutritionPlan = plan
        let lOption = MealOption(optionNumber: 1)
        lOption.meal = lunch
        lOption.items = [
            makeItem(food: chicken, grams: 200),
            makeItem(food: rice, grams: 200)
        ]
        lunch.options = [lOption]

        let dinner = Meal(name: "Dinner", mealType: .dinner, order: 2, targetCalories: 700, targetProteinG: 45, targetCarbsG: 60, targetFatG: 20)
        dinner.nutritionPlan = plan
        let dOption = MealOption(optionNumber: 1)
        dOption.meal = dinner
        dOption.items = [
            makeItem(food: eggs, grams: 180),
            makeItem(food: sweetPotato, grams: 150)
        ]
        dinner.options = [dOption]

        plan.meals = [breakfast, lunch, dinner]

        let todayLog = DailyNutritionLog(date: .now, adherenceStatus: .partial)
        let bfLog = MealLog(wasFollowed: true)
        bfLog.meal = breakfast
        bfLog.selectedOption = bfOption
        bfLog.dailyLog = todayLog
        let lunchLog = MealLog(wasFollowed: true)
        lunchLog.meal = lunch
        lunchLog.selectedOption = lOption
        lunchLog.dailyLog = todayLog
        todayLog.mealLogs = [bfLog, lunchLog]

        vm.plan = plan
        vm.todayLog = todayLog
        vm.summary = DailyMacroSummary(
            consumedCalories: 1450,
            consumedProteinG: 110,
            consumedCarbsG: 140,
            consumedFatG: 40,
            targetCalories: 2800,
            targetProteinG: 180,
            targetCarbsG: 320,
            targetFatG: 75
        )

        return vm
    }

    static var withError: MockPlanOverviewViewModel {
        let vm = MockPlanOverviewViewModel()
        vm.errorMessage = L10n.Nutrition.Error.loadFailed
        return vm
    }

    private static func makeItem(food: FoodItem, grams: Double) -> MealOptionItem {
        let item = MealOptionItem(amountGrams: grams)
        item.foodItem = food
        return item
    }
}

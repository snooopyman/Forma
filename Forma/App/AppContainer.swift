//
//  AppContainer.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftData
import Observation

@Observable
final class AppContainer {

    // MARK: - Repositories

    let userProfileRepository: UserProfileRepositoryProtocol
    let mesocycleRepository: MesocycleRepositoryProtocol
    let workoutSessionRepository: WorkoutSessionRepositoryProtocol
    let bodyMeasurementRepository: BodyMeasurementRepositoryProtocol
    let nutritionRepository: NutritionRepositoryProtocol
    let foodItemRepository: FoodItemRepositoryProtocol

    // MARK: - Initializers

    init(modelContext: ModelContext) {
        self.userProfileRepository = UserProfileRepository(modelContext: modelContext)
        self.mesocycleRepository = MesocycleRepository(modelContext: modelContext)
        self.workoutSessionRepository = WorkoutSessionRepository(modelContext: modelContext)
        self.bodyMeasurementRepository = BodyMeasurementRepository(modelContext: modelContext)
        self.nutritionRepository = NutritionRepository(modelContext: modelContext)
        self.foodItemRepository = FoodItemRepository(modelContext: modelContext)
    }
}

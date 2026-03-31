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

    // MARK: - Services

    let workoutSessionService: WorkoutSessionServiceProtocol
    let volumeCalculatorService: VolumeCalculatorServiceProtocol
    let restTimerActivityService: RestTimerActivityServiceProtocol

    // MARK: - Initializers

    init(modelContext: ModelContext) {
        self.userProfileRepository = UserProfileRepository(modelContext: modelContext)
        self.mesocycleRepository = MesocycleRepository(modelContext: modelContext)
        let sessionRepo = WorkoutSessionRepository(modelContext: modelContext)
        self.workoutSessionRepository = sessionRepo
        self.bodyMeasurementRepository = BodyMeasurementRepository(modelContext: modelContext)
        self.nutritionRepository = NutritionRepository(modelContext: modelContext)
        self.foodItemRepository = FoodItemRepository(modelContext: modelContext)
        self.workoutSessionService = WorkoutSessionService(sessionRepository: sessionRepo)
        self.volumeCalculatorService = VolumeCalculatorService()
        self.restTimerActivityService = RestTimerActivityService()
    }
}

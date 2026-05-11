//
//  AppContainer.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class AppContainer {

    // MARK: - Repositories

    let userProfileRepository: UserProfileRepositoryProtocol
    let mesocycleRepository: MesocycleRepositoryProtocol
    let workoutSessionRepository: WorkoutSessionRepositoryProtocol
    let bodyMeasurementRepository: BodyMeasurementRepositoryProtocol
    let progressPhotoRepository: ProgressPhotoRepositoryProtocol
    let nutritionRepository: NutritionRepositoryProtocol
    let foodItemRepository: FoodItemRepositoryProtocol

    // MARK: - Services

    let workoutSessionService: WorkoutSessionServiceProtocol
    let volumeCalculatorService: VolumeCalculatorServiceProtocol
    let restTimerActivityService: RestTimerActivityServiceProtocol
    let macroTrackingService: MacroTrackingServiceProtocol
    let bodyMetricsService: BodyMetricsServiceProtocol
    let healthKitService: HealthKitServiceProtocol

    // MARK: - Initializers

    init(modelContext: ModelContext) {
        self.userProfileRepository = UserProfileRepository(modelContext: modelContext)
        self.mesocycleRepository = MesocycleRepository(modelContext: modelContext)
        let sessionRepo = WorkoutSessionRepository(modelContext: modelContext)
        self.workoutSessionRepository = sessionRepo
        self.bodyMeasurementRepository = BodyMeasurementRepository(modelContext: modelContext)
        self.progressPhotoRepository = ProgressPhotoRepository(modelContext: modelContext)
        self.nutritionRepository = NutritionRepository(modelContext: modelContext)
        self.foodItemRepository = FoodItemRepository(modelContext: modelContext)
        self.workoutSessionService = WorkoutSessionService(sessionRepository: sessionRepo)
        self.volumeCalculatorService = VolumeCalculatorService()
        self.restTimerActivityService = RestTimerActivityService()
        self.macroTrackingService = MacroTrackingService()
        self.bodyMetricsService = BodyMetricsService()
        self.healthKitService = HealthKitService()

        let catalogSeeded = UserDefaults.standard.bool(forKey: "com.armando.forma.foodCatalogV1")
        if !catalogSeeded {
            let descriptor = FetchDescriptor<FoodItem>(predicate: #Predicate { !$0.isCustom })
            if let existing = try? modelContext.fetch(descriptor) {
                existing.forEach { modelContext.delete($0) }
            }
            FoodCatalog.catalog.forEach { modelContext.insert($0) }
            try? modelContext.save()
            UserDefaults.standard.set(true, forKey: "com.armando.forma.foodCatalogV1")
        }
    }
}

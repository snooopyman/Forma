//
//  AppContainer.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI
import SwiftData
import Observation
import os

@Observable
final class AppContainer {
    
    // MARK: - Repositories
    
    let userProfileRepository: UserProfileRepositoryProtocol
    let mesocycleRepository: MesocycleRepositoryProtocol
    let workoutSessionRepository: WorkoutSessionRepositoryProtocol
    let bodyMeasurementRepository: BodyMeasurementRepositoryProtocol
    let progressPhotoRepository: ProgressPhotoRepositoryProtocol
    let muscleVolumeTargetRepository: MuscleVolumeTargetRepositoryProtocol
    let nutritionRepository: NutritionRepositoryProtocol
    let foodItemRepository: FoodItemRepositoryProtocol
    
    // MARK: - Services
    
    let workoutSessionService: WorkoutSessionServiceProtocol
    let volumeCalculatorService: VolumeCalculatorServiceProtocol
    let restTimerActivityService: RestTimerActivityServiceProtocol
    let macroTrackingService: MacroTrackingServiceProtocol
    let bodyMetricsService: BodyMetricsServiceProtocol
    let healthKitService: HealthKitServiceProtocol
    let notificationService: NotificationServiceProtocol
    let measurementReminderScheduler: MeasurementReminderSchedulerProtocol
    
    // MARK: - Initializers
    
    init(modelContext: ModelContext) {
        self.userProfileRepository = UserProfileRepository(modelContext: modelContext)
        self.mesocycleRepository = MesocycleRepository(modelContext: modelContext)
        let sessionRepo = WorkoutSessionRepository(modelContext: modelContext)
        self.workoutSessionRepository = sessionRepo
        self.bodyMeasurementRepository = BodyMeasurementRepository(modelContext: modelContext)
        self.progressPhotoRepository = ProgressPhotoRepository(modelContext: modelContext)
        self.muscleVolumeTargetRepository = MuscleVolumeTargetRepository(modelContext: modelContext)
        self.nutritionRepository = NutritionRepository(modelContext: modelContext)
        self.foodItemRepository = FoodItemRepository(modelContext: modelContext)
        self.workoutSessionService = WorkoutSessionService(sessionRepository: sessionRepo)
        self.volumeCalculatorService = VolumeCalculatorService()
        self.restTimerActivityService = RestTimerActivityService()
        self.macroTrackingService = MacroTrackingService()
        self.bodyMetricsService = BodyMetricsService()
        self.healthKitService = HealthKitService()
        self.notificationService = NotificationService()
        self.measurementReminderScheduler = MeasurementReminderScheduler(
            userProfileRepository: userProfileRepository,
            measurementRepository: bodyMeasurementRepository,
            notificationService: notificationService
        )
        
        Self.repairDanglingMealOptionItemReferences(modelContext: modelContext)
        Self.reconcileFoodCatalog(modelContext: modelContext)
    }
    
    // MARK: - Private Functions
    
    private static func repairDanglingMealOptionItemReferences(modelContext: ModelContext) {
        do {
            let validFoodItemIDs = try modelContext.fetch(FetchDescriptor<FoodItem>()).map(\.id)
            
            var validlyReferencedIDs: Set<UUID> = []
            for foodItemID in validFoodItemIDs {
                let referencing = try modelContext.fetch(
                    FetchDescriptor<MealOptionItem>(predicate: #Predicate { $0.foodItem?.id == foodItemID })
                )
                for mealOptionItem in referencing {
                    validlyReferencedIDs.insert(mealOptionItem.id)
                }
            }
            
            let itemsWithAFoodItem = try modelContext.fetch(
                FetchDescriptor<MealOptionItem>(predicate: #Predicate { $0.foodItem != nil })
            )
            let danglingItems = itemsWithAFoodItem.filter { !validlyReferencedIDs.contains($0.id) }
            guard !danglingItems.isEmpty else { return }
            
            for item in danglingItems {
                item.foodItem = nil
            }
            try modelContext.save()
        } catch {
            Logger.core.error("Dangling meal option item repair failed: \(error, privacy: .public)")
        }
    }
    
    private static func reconcileFoodCatalog(modelContext: ModelContext) {
        do {
            let catalogItems = FoodCatalog.catalog
            let catalogByName = Dictionary(uniqueKeysWithValues: catalogItems.map { ($0.name, $0) })
            let existingNonCustom = try modelContext.fetch(
                FetchDescriptor<FoodItem>(predicate: #Predicate { !$0.isCustom })
            )
            
            var usageCounts: [(item: FoodItem, count: Int)] = []
            for item in existingNonCustom {
                let itemID = item.id
                let count = try modelContext.fetchCount(
                    FetchDescriptor<MealOptionItem>(predicate: #Predicate { $0.foodItem?.id == itemID })
                )
                usageCounts.append((item, count))
            }
            
            var seenNames: Set<String> = []
            for (item, count) in usageCounts where count > 0 {
                seenNames.insert(item.name)
            }
            
            var survivingItems = usageCounts.filter { $0.count > 0 }.map(\.item)
            for (item, count) in usageCounts where count == 0 {
                if catalogByName[item.name] == nil || seenNames.contains(item.name) {
                    modelContext.delete(item)
                } else {
                    seenNames.insert(item.name)
                    survivingItems.append(item)
                }
            }
            
            for catalogItem in catalogItems where !seenNames.contains(catalogItem.name) {
                modelContext.insert(catalogItem)
            }
            
            for item in survivingItems {
                guard let catalogItem = catalogByName[item.name] else { continue }
                item.catalogKey = catalogItem.catalogKey
                item.categoryKey = catalogItem.categoryKey
            }
            
            try modelContext.save()
        } catch {
            Logger.core.error("Food catalog reconciliation failed: \(error, privacy: .public)")
        }
    }
}

//
//  ActiveSessionInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation
import HealthKit

final class ActiveSessionInteractor: ActiveSessionInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let sessionService: WorkoutSessionServiceProtocol
    private let restTimerActivityService: RestTimerActivityServiceProtocol
    private let healthKitService: HealthKitServiceProtocol
    
    // MARK: - Initializers
    
    init(
        sessionService: WorkoutSessionServiceProtocol,
        restTimerActivityService: RestTimerActivityServiceProtocol,
        healthKitService: HealthKitServiceProtocol
    ) {
        self.sessionService = sessionService
        self.restTimerActivityService = restTimerActivityService
        self.healthKitService = healthKitService
    }
    
    // MARK: - Functions
    
    func logSet(_ input: SetInput, order: Int, to session: WorkoutSession, plannedExercise: PlannedExercise?) async throws -> LoggedSet {
        try await sessionService.logSet(input, order: order, to: session, plannedExercise: plannedExercise)
    }
    
    func deleteSet(_ set: LoggedSet, from session: WorkoutSession) async throws {
        try await sessionService.deleteSet(set, from: session)
    }
    
    func completeSession(_ session: WorkoutSession) async throws {
        try await sessionService.completeSession(session)
    }
    
    func discardSession(_ session: WorkoutSession) async throws {
        try await sessionService.discardSession(session)
    }
    
    func fetchLastSets(for workoutDay: WorkoutDay, exerciseName: String) async throws -> [LoggedSet] {
        try await sessionService.fetchLastSets(for: workoutDay, exerciseName: exerciseName)
    }
    
    func startRestActivity(exerciseName: String, seconds: Int) async {
        await restTimerActivityService.startActivity(exerciseName: exerciseName, seconds: seconds)
    }
    
    func endRestActivity() async {
        await restTimerActivityService.endActivity()
    }
    
    func writeWorkout(activityType: HKWorkoutActivityType, start: Date, end: Date) async {
        await healthKitService.writeWorkout(activityType: activityType, start: start, end: end)
    }
}

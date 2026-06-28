//
//  MockActiveSessionInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation
import HealthKit

final class MockActiveSessionInteractor: ActiveSessionInteractorProtocol {
    
    // MARK: - Stub Data
    
    var stubbedLoggedSet: LoggedSet?
    var stubbedLastSets: [LoggedSet] = []
    var shouldThrowOnLogSet = false
    var shouldThrowOnDeleteSet = false
    var shouldThrowOnComplete = false
    var shouldThrowOnDiscard = false
    
    // MARK: - Functions
    
    func logSet(_ input: SetInput, order: Int, to session: WorkoutSession, plannedExercise: PlannedExercise?) async throws -> LoggedSet {
        if shouldThrowOnLogSet { throw TrainingError.logSetFailed }
        guard let set = stubbedLoggedSet else { throw TrainingError.logSetFailed }
        return set
    }
    
    func deleteSet(_ set: LoggedSet, from session: WorkoutSession) async throws {
        if shouldThrowOnDeleteSet { throw TrainingError.deleteFailed }
    }
    
    func completeSession(_ session: WorkoutSession) async throws {
        if shouldThrowOnComplete { throw TrainingError.finishFailed }
    }
    
    func discardSession(_ session: WorkoutSession) async throws {
        if shouldThrowOnDiscard { throw TrainingError.deleteFailed }
    }
    
    func fetchLastSets(for workoutDay: WorkoutDay, exerciseName: String) async throws -> [LoggedSet] {
        stubbedLastSets
    }
    
    func startRestActivity(exerciseName: String, seconds: Int) async { }
    
    func endRestActivity() async { }
    
    func writeWorkout(activityType: HKWorkoutActivityType, start: Date, end: Date) async { }
}

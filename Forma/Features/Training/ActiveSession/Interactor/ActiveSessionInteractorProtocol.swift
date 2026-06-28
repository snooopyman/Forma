//
//  ActiveSessionInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation
import HealthKit

protocol ActiveSessionInteractorProtocol: Sendable {
    func logSet(_ input: SetInput, order: Int, to session: WorkoutSession, plannedExercise: PlannedExercise?) async throws -> LoggedSet
    func deleteSet(_ set: LoggedSet, from session: WorkoutSession) async throws
    func completeSession(_ session: WorkoutSession) async throws
    func discardSession(_ session: WorkoutSession) async throws
    func fetchLastSets(for workoutDay: WorkoutDay, exerciseName: String) async throws -> [LoggedSet]
    func startRestActivity(exerciseName: String, seconds: Int) async
    func endRestActivity() async
    func writeWorkout(activityType: HKWorkoutActivityType, start: Date, end: Date) async
}

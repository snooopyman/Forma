//
//  ActiveSessionTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
import Foundation
import HealthKit
@testable import Forma

extension ActiveSessionTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: ActiveSessionInteractor

        // MARK: - Spies

        let spySessionService: SpyWorkoutSessionService
        let spyRestTimerActivityService: SpyRestTimerActivityService
        let spyHealthKitService: SpyHealthKitService

        // MARK: - Initializers

        init() {
            spySessionService = SpyWorkoutSessionService()
            spyRestTimerActivityService = SpyRestTimerActivityService()
            spyHealthKitService = SpyHealthKitService()
            sut = ActiveSessionInteractor(
                sessionService: spySessionService,
                restTimerActivityService: spyRestTimerActivityService,
                healthKitService: spyHealthKitService
            )
        }

        @Test("logSet delegates to session service")
        func logSetTracked() async throws {
            let session = WorkoutSession()
            let input = SetInput(exerciseName: "Bench Press", weightKg: 80, reps: 8)
            spySessionService.stubbedLoggedSet = LoggedSet(order: 1, exerciseName: "Bench Press", weightKg: 80, reps: 8)
            let result = try await sut.logSet(input, order: 1, to: session, plannedExercise: nil)
            #expect(spySessionService.logSetWasCalled == true)
            #expect(result.weightKg == 80)
        }

        @Test("logSet propagates error")
        func logSetPropagatesError() async {
            let session = WorkoutSession()
            let input = SetInput(exerciseName: "Deadlift", weightKg: 100, reps: 5)
            spySessionService.shouldThrowError = true
            spySessionService.errorToThrow = TrainingError.logSetFailed
            await #expect(throws: TrainingError.self) {
                _ = try await sut.logSet(input, order: 1, to: session, plannedExercise: nil)
            }
        }

        @Test("deleteSet delegates to session service")
        func deleteSetTracked() async throws {
            let session = WorkoutSession()
            let set = LoggedSet(order: 1, exerciseName: "Squat", weightKg: 100, reps: 5)
            try await sut.deleteSet(set, from: session)
            #expect(spySessionService.deleteSetWasCalled == true)
        }

        @Test("completeSession delegates to session service")
        func completeSessionTracked() async throws {
            let session = WorkoutSession()
            try await sut.completeSession(session)
            #expect(spySessionService.completeSessionWasCalled == true)
            #expect(spySessionService.lastCompletedSession?.id == session.id)
        }

        @Test("discardSession delegates to session service")
        func discardSessionTracked() async throws {
            let session = WorkoutSession()
            try await sut.discardSession(session)
            #expect(spySessionService.discardSessionWasCalled == true)
            #expect(spySessionService.lastDiscardedSession?.id == session.id)
        }

        @Test("fetchLastSets delegates to session service")
        func fetchLastSetsTracked() async throws {
            let day = WorkoutDay(name: "Push", order: 0)
            spySessionService.stubbedLastSets = [LoggedSet(order: 1, exerciseName: "Bench Press", weightKg: 80, reps: 8)]
            let sets = try await sut.fetchLastSets(for: day, exerciseName: "Bench Press")
            #expect(spySessionService.fetchLastSetsWasCalled == true)
            #expect(sets.count == 1)
        }

        @Test("startRestActivity delegates to rest timer service")
        func startRestActivityTracked() async {
            await sut.startRestActivity(exerciseName: "Bench Press", seconds: 90)
            #expect(spyRestTimerActivityService.startActivityWasCalled == true)
            #expect(spyRestTimerActivityService.lastExerciseName == "Bench Press")
            #expect(spyRestTimerActivityService.lastSeconds == 90)
        }

        @Test("endRestActivity delegates to rest timer service")
        func endRestActivityTracked() async {
            await sut.endRestActivity()
            #expect(spyRestTimerActivityService.endActivityWasCalled == true)
        }

        @Test("writeWorkout delegates to HealthKit service")
        func writeWorkoutTracked() async {
            await sut.writeWorkout(activityType: .traditionalStrengthTraining, start: .now, end: .now)
            #expect(spyHealthKitService.writeWorkoutWasCalled == true)
            #expect(spyHealthKitService.lastWrittenWorkoutType == .traditionalStrengthTraining)
        }
    }
}

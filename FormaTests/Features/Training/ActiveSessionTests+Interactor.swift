//
//  ActiveSessionTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
@testable import Forma

extension ActiveSessionTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        let spy: SpyActiveSessionInteractor

        init() {
            spy = SpyActiveSessionInteractor()
        }

        @Test("completeSession is tracked by spy")
        func completeSessionTracked() async throws {
            let session = WorkoutSession()
            try await spy.completeSession(session)
            #expect(spy.completeSessionWasCalled == true)
            #expect(spy.lastCompletedSession?.id == session.id)
        }

        @Test("discardSession is tracked by spy")
        func discardSessionTracked() async throws {
            let session = WorkoutSession()
            try await spy.discardSession(session)
            #expect(spy.discardSessionWasCalled == true)
            #expect(spy.lastDiscardedSession?.id == session.id)
        }

        @Test("logSet returns stubbed LoggedSet")
        func logSetReturnsStubbedValue() async throws {
            let session = WorkoutSession()
            let input = SetInput(exerciseName: "Bench Press", weightKg: 80, reps: 8)
            let set = try await spy.logSet(input, order: 1, to: session, plannedExercise: nil)
            #expect(spy.logSetWasCalled == true)
            #expect(set.exerciseName == "Bench Press")
            #expect(set.weightKg == 80)
            #expect(set.reps == 8)
        }

        @Test("logSet propagates error")
        func logSetPropagatesError() async {
            let session = WorkoutSession()
            let input = SetInput(exerciseName: "Deadlift", weightKg: 100, reps: 5)
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.logSetFailed
            await #expect(throws: TrainingError.self) {
                _ = try await spy.logSet(input, order: 1, to: session, plannedExercise: nil)
            }
        }

        @Test("reset clears all tracking flags")
        func resetClearsFlags() async throws {
            let session = WorkoutSession()
            try await spy.completeSession(session)
            spy.reset()
            #expect(spy.completeSessionWasCalled == false)
            #expect(spy.lastCompletedSession == nil)
        }
    }
}

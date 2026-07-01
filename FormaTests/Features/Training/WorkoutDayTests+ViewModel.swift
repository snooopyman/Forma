//
//  WorkoutDayTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
@testable import Forma

extension WorkoutDayTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: WorkoutDayDetailViewModel
        let spy: SpyWorkoutDayInteractor
        let workoutDay: WorkoutDay

        init() {
            spy = SpyWorkoutDayInteractor()
            workoutDay = WorkoutDay(name: "Push", order: 0)
            sut = WorkoutDayDetailViewModel(workoutDay: workoutDay, interactor: spy)
        }

        @Test("load() fetches the in-progress session")
        func loadSuccess() async {
            let session = WorkoutSession()
            spy.stubbedInProgressSession = session
            await sut.load()
            #expect(spy.fetchInProgressSessionWasCalled == true)
            #expect(sut.inProgressSession?.id == session.id)
        }

        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == TrainingError.loadFailed.errorDescription)
        }

        @Test("deleteExercise() calls the interactor")
        func deleteExerciseSuccess() async {
            let planned = PlannedExercise(order: 0)
            await sut.deleteExercise(planned)
            #expect(spy.deletePlannedExerciseWasCalled == true)
            #expect(spy.lastDeletedExercise?.id == planned.id)
        }

        @Test("startSession() throws when the day has no mesocycle")
        func startSessionNoMesocycle() async {
            await #expect(throws: WorkoutDayError.self) {
                _ = try await sut.startSession()
            }
        }

        @Test("startSession() returns the started session")
        func startSessionSuccess() async throws {
            let mesocycle = Mesocycle(name: "Block 1")
            workoutDay.mesocycle = mesocycle
            let session = WorkoutSession()
            spy.stubbedStartedSession = session
            let result = try await sut.startSession()
            #expect(spy.startSessionWasCalled == true)
            #expect(result.id == session.id)
            #expect(sut.isStarting == false)
        }

        @Test("addPlannedExercise() builds and adds a new exercise")
        func addPlannedExerciseSuccess() async {
            await sut.addPlannedExercise(name: "Bench Press", muscle: .chest, sets: 4, repsMin: 6, repsMax: 10, rir: 2, restSeconds: 120)
            #expect(spy.addPlannedExerciseWasCalled == true)
            #expect(spy.lastAddedExercise?.sets == 4)
            #expect(workoutDay.plannedExercises.count == 1)
        }

        @Test("addPlannedExercise() sets errorMessage on failure")
        func addPlannedExerciseFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.saveFailed
            await sut.addPlannedExercise(name: "Bench Press", muscle: .chest, sets: 4, repsMin: 6, repsMax: 10, rir: 2, restSeconds: 120)
            #expect(sut.errorMessage == TrainingError.saveFailed.errorDescription)
        }

        @Test("updatePlannedExercise() calls the interactor")
        func updatePlannedExerciseSuccess() async {
            let planned = PlannedExercise(order: 0)
            await sut.updatePlannedExercise(planned, name: "Incline Press", muscle: .chest, sets: 3, repsMin: 8, repsMax: 12, rir: 1, restSeconds: 90)
            #expect(spy.updatePlannedExerciseWasCalled == true)
            #expect(spy.lastUpdatedExercise?.id == planned.id)
        }

        @Test("canStartSession is false when the mesocycle is inactive")
        func canStartSessionInactiveMesocycle() {
            let mesocycle = Mesocycle(name: "Block 1", isActive: false)
            workoutDay.mesocycle = mesocycle
            workoutDay.plannedExercises = [PlannedExercise(order: 0)]
            #expect(sut.canStartSession == false)
        }

        @Test("canStartSession is true when active, unpaused, non-rest, with exercises")
        func canStartSessionTrue() {
            let mesocycle = Mesocycle(name: "Block 1", isActive: true)
            workoutDay.mesocycle = mesocycle
            workoutDay.plannedExercises = [PlannedExercise(order: 0)]
            #expect(sut.canStartSession == true)
        }
    }
}

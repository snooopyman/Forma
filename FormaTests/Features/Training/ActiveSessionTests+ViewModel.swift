//
//  ActiveSessionTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
import Foundation
@testable import Forma

extension ActiveSessionTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: ActiveSessionViewModel
        let spy: SpyActiveSessionInteractor
        let session: WorkoutSession
        let workoutDay: WorkoutDay

        init() {
            spy = SpyActiveSessionInteractor()
            session = WorkoutSession()
            workoutDay = WorkoutDay(name: "Push Day", order: 0)
            sut = ActiveSessionViewModel(session: session, workoutDay: workoutDay, interactor: spy)
        }

        @Test("navigateNext increments currentExerciseIndex")
        func navigateNext() {
            sut.currentExerciseIndex = 0
            sut.navigateNext()
            #expect(sut.currentExerciseIndex == 0)
        }

        @Test("navigatePrevious does nothing when at index 0")
        func navigatePreviousGuard() {
            sut.currentExerciseIndex = 0
            sut.navigatePrevious()
            #expect(sut.currentExerciseIndex == 0)
        }

        @Test("completeSession calls interactor and sets isCompleted")
        func completeSessionSuccess() async {
            await sut.completeSession()
            #expect(spy.completeSessionWasCalled == true)
            #expect(sut.isCompleted == true)
            #expect(sut.errorMessage == nil)
        }

        @Test("completeSession sets errorMessage on failure")
        func completeSessionFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.finishFailed
            await sut.completeSession()
            #expect(sut.errorMessage == TrainingError.finishFailed.errorDescription)
            #expect(sut.isCompleted == false)
        }

        @Test("discardSession calls interactor and sets isCompleted")
        func discardSessionSuccess() async {
            await sut.discardSession()
            #expect(spy.discardSessionWasCalled == true)
            #expect(sut.isCompleted == true)
        }

        @Test("logSet validates empty weight input")
        func logSetValidatesInput() async {
            let exercise = PlannedExercise(order: 0)
            sut.weightInputs[exercise.id] = ""
            sut.repsInputs[exercise.id] = ""
            await sut.logSet(for: exercise)
            #expect(spy.logSetWasCalled == false)
            #expect(sut.errorMessage == String(localized: "Enter valid weight and reps"))
        }

        @Test("setRowState returns correct state")
        func setRowState() {
            let exercise = PlannedExercise(order: 0)
            #expect(sut.setRowState(setNumber: 1, for: exercise) == .active)
            #expect(sut.setRowState(setNumber: 2, for: exercise) == .pending)
        }

        @Test("skipRest cancels timer and resets resting state")
        func skipRest() {
            sut.isResting = true
            sut.restSecondsRemaining = 60
            sut.skipRest()
            #expect(sut.restSecondsRemaining == 0)
            #expect(sut.isResting == false)
        }

        @Test("loadReferenceSets caches last sets, exposing a reference set and a suggested target")
        func loadReferenceSetsPopulatesSuggestion() async {
            let exercise = Exercise(name: "Bench Press", primaryMuscle: .chest, equipment: EquipmentType.barbell.rawValue)
            let planned = PlannedExercise(order: 0, repsMin: 8, repsMax: 10, rirTarget: 2)
            planned.exercise = exercise
            spy.stubbedLastSets = [LoggedSet(order: 1, exerciseName: "Bench Press", weightKg: 100, reps: 10, rirActual: 2)]

            await sut.loadReferenceSets(for: planned)

            #expect(sut.referenceSet(for: planned)?.weightKg == 100)
            #expect(sut.suggestedTarget(for: planned)?.suggestedWeightKg == 102.5)
            #expect(sut.suggestedTarget(for: planned)?.suggestedReps == 8)
        }

        @Test("applySuggestion writes the suggested weight and reps into the inputs")
        func applySuggestionWritesInputs() async {
            let exercise = Exercise(name: "Bench Press", primaryMuscle: .chest, equipment: EquipmentType.barbell.rawValue)
            let planned = PlannedExercise(order: 0, repsMin: 8, repsMax: 10, rirTarget: 2)
            planned.exercise = exercise
            spy.stubbedLastSets = [LoggedSet(order: 1, exerciseName: "Bench Press", weightKg: 100, reps: 10, rirActual: 2)]

            await sut.loadReferenceSets(for: planned)
            sut.applySuggestion(for: planned)

            #expect(sut.weightInputs[planned.id]?.weightDouble == 102.5)
            #expect(sut.repsInputs[planned.id] == "8")
        }

        @Test("No suggestion is offered when the exercise was skipped in the last completed session")
        func noSuggestionWhenSkippedLastTime() async {
            let exercise = Exercise(name: "Bench Press", primaryMuscle: .chest, equipment: EquipmentType.barbell.rawValue)
            let planned = PlannedExercise(order: 0)
            planned.exercise = exercise
            spy.stubbedLastSets = []

            await sut.loadReferenceSets(for: planned)
            sut.applySuggestion(for: planned)

            #expect(sut.referenceSet(for: planned) == nil)
            #expect(sut.suggestedTarget(for: planned) == nil)
            #expect(sut.weightInputs[planned.id] == nil)
            #expect(sut.repsInputs[planned.id] == nil)
        }
    }
}

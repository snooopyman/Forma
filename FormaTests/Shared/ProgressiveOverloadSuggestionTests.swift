//
//  ProgressiveOverloadSuggestionTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 10/7/26.
//

import Testing
import Foundation
@testable import Forma

@Suite("Progressive Overload Suggestion")
struct ProgressiveOverloadSuggestionTests {

    // MARK: - Reference set selection

    @Test("referenceSet returns nil when there are no last sets")
    func referenceSetEmpty() {
        #expect(ProgressiveOverloadSuggestion.referenceSet(from: [], setNumber: 1) == nil)
    }

    @Test("referenceSet matches the same set number when it exists")
    func referenceSetExactMatch() {
        let set1 = LoggedSet(order: 1, exerciseName: "Bench Press", weightKg: 50, reps: 8, rirActual: 2)
        let set2 = LoggedSet(order: 2, exerciseName: "Bench Press", weightKg: 40, reps: 8, rirActual: 0)
        let set3 = LoggedSet(order: 3, exerciseName: "Bench Press", weightKg: 38, reps: 8, rirActual: 4)
        let lastSets = [set1, set2, set3]
        #expect(ProgressiveOverloadSuggestion.referenceSet(from: lastSets, setNumber: 1)?.id == set1.id)
        #expect(ProgressiveOverloadSuggestion.referenceSet(from: lastSets, setNumber: 2)?.id == set2.id)
        #expect(ProgressiveOverloadSuggestion.referenceSet(from: lastSets, setNumber: 3)?.id == set3.id)
    }

    @Test("referenceSet carries the last available set forward when fewer sets were logged last time")
    func referenceSetCarriesForward() {
        let set1 = LoggedSet(order: 1, exerciseName: "Bench Press", weightKg: 50, reps: 8, rirActual: 2)
        let lastSets = [set1]
        #expect(ProgressiveOverloadSuggestion.referenceSet(from: lastSets, setNumber: 2)?.id == set1.id)
        #expect(ProgressiveOverloadSuggestion.referenceSet(from: lastSets, setNumber: 4)?.id == set1.id)
    }

    @Test("suggest returns nil when there are no last sets")
    func suggestNoLastSets() {
        let planned = PlannedExercise(order: 0)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [], setNumber: 1, plannedExercise: planned, equipment: .barbell)
        #expect(result == nil)
    }

    // MARK: - Rule 1: increase weight

    @Test("Barbell at repsMax with RIR met increases weight by 2.5%, rounded to 0.5, resets to repsMin")
    func increaseWeightBarbell() {
        let planned = PlannedExercise(order: 0, repsMin: 8, repsMax: 10, rirTarget: 2)
        let lastSet = LoggedSet(order: 1, exerciseName: "Squat", weightKg: 100, reps: 10, rirActual: 2)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [lastSet], setNumber: 1, plannedExercise: planned, equipment: .barbell)
        #expect(result?.suggestedWeightKg == 102.5)
        #expect(result?.suggestedReps == 8)
    }

    @Test("Dumbbell at repsMax with RIR met increases weight by 5%")
    func increaseWeightDumbbell() {
        let planned = PlannedExercise(order: 0, repsMin: 10, repsMax: 12, rirTarget: 2)
        let lastSet = LoggedSet(order: 1, exerciseName: "Lateral Raise", weightKg: 20, reps: 12, rirActual: 2)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [lastSet], setNumber: 1, plannedExercise: planned, equipment: .dumbbell)
        #expect(result?.suggestedWeightKg == 21.0)
        #expect(result?.suggestedReps == 10)
    }

    @Test("Unspecified equipment falls back to 2.5% like barbell")
    func increaseWeightUnspecified() {
        let planned = PlannedExercise(order: 0, repsMin: 8, repsMax: 10, rirTarget: 2)
        let lastSet = LoggedSet(order: 1, exerciseName: "Machine Press", weightKg: 100, reps: 10, rirActual: 2)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [lastSet], setNumber: 1, plannedExercise: planned, equipment: nil)
        #expect(result?.suggestedWeightKg == 102.5)
        #expect(result?.suggestedReps == 8)
    }

    @Test("Nil rirActual is treated as RIR target met")
    func increaseWeightNilRIR() {
        let planned = PlannedExercise(order: 0, repsMin: 8, repsMax: 10, rirTarget: 2)
        let lastSet = LoggedSet(order: 1, exerciseName: "Squat", weightKg: 100, reps: 10, rirActual: nil)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [lastSet], setNumber: 1, plannedExercise: planned, equipment: .barbell)
        #expect(result?.suggestedWeightKg == 102.5)
    }

    @Test("Weighted bodyweight exercise at repsMax with RIR met increases the added load")
    func increaseWeightLoadedBodyweight() {
        let planned = PlannedExercise(order: 0, repsMin: 5, repsMax: 8, rirTarget: 2)
        let lastSet = LoggedSet(order: 1, exerciseName: "Weighted Pull-Up", weightKg: 10, reps: 9, rirActual: 3)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [lastSet], setNumber: 1, plannedExercise: planned, equipment: .bodyweight)
        #expect(result?.suggestedWeightKg == 10.5)
        #expect(result?.suggestedReps == 5)
    }

    // MARK: - Rule 2: increase reps

    @Test("Below repsMax increases reps by one, regardless of RIR")
    func increaseReps() {
        let planned = PlannedExercise(order: 0, repsMin: 8, repsMax: 12, rirTarget: 2)
        let lastSet = LoggedSet(order: 1, exerciseName: "Bench Press", weightKg: 60, reps: 8, rirActual: 0)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [lastSet], setNumber: 1, plannedExercise: planned, equipment: .barbell)
        #expect(result?.suggestedWeightKg == 60)
        #expect(result?.suggestedReps == 9)
    }

    @Test("Unloaded bodyweight exercise at repsMax stays capped at repsMax")
    func increaseRepsUnloadedBodyweightCapped() {
        let planned = PlannedExercise(order: 0, repsMin: 5, repsMax: 8, rirTarget: 2)
        let lastSet = LoggedSet(order: 1, exerciseName: "Pull-Up", weightKg: 0, reps: 8, rirActual: 2)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [lastSet], setNumber: 1, plannedExercise: planned, equipment: .bodyweight)
        #expect(result?.suggestedWeightKg == 0)
        #expect(result?.suggestedReps == 8)
    }

    // MARK: - Rule 3: maintain

    @Test("At repsMax but RIR below target maintains weight and reps")
    func maintain() {
        let planned = PlannedExercise(order: 0, repsMin: 8, repsMax: 10, rirTarget: 2)
        let lastSet = LoggedSet(order: 1, exerciseName: "Deadlift", weightKg: 80, reps: 10, rirActual: 0)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [lastSet], setNumber: 1, plannedExercise: planned, equipment: .barbell)
        #expect(result?.suggestedWeightKg == 80)
        #expect(result?.suggestedReps == 10)
    }

    // MARK: - Per-set matching across a real multi-set session

    @Test("Each set compares against the matching set number from last time, not always the first")
    func perSetMatching() {
        // Top set at repsMax with RIR met → increase weight. Backoff sets below repsMax → increase reps.
        let planned = PlannedExercise(order: 0, repsMin: 6, repsMax: 8, rirTarget: 2)
        let set1 = LoggedSet(order: 1, exerciseName: "Bench Press", weightKg: 50, reps: 8, rirActual: 2)
        let set2 = LoggedSet(order: 2, exerciseName: "Bench Press", weightKg: 40, reps: 6, rirActual: 0)
        let lastSets = [set1, set2]

        let resultSet1 = ProgressiveOverloadSuggestion.suggest(lastSets: lastSets, setNumber: 1, plannedExercise: planned, equipment: .barbell)
        #expect(resultSet1?.suggestedWeightKg == 51.5)
        #expect(resultSet1?.suggestedReps == 6)

        let resultSet2 = ProgressiveOverloadSuggestion.suggest(lastSets: lastSets, setNumber: 2, plannedExercise: planned, equipment: .barbell)
        #expect(resultSet2?.suggestedWeightKg == 40)
        #expect(resultSet2?.suggestedReps == 7)
    }

    @Test("A set beyond what was logged last time carries the last available set forward")
    func suggestCarriesForward() {
        let planned = PlannedExercise(order: 0, repsMin: 6, repsMax: 8, rirTarget: 2)
        let set1 = LoggedSet(order: 1, exerciseName: "Bench Press", weightKg: 50, reps: 6, rirActual: 0)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [set1], setNumber: 3, plannedExercise: planned, equipment: .barbell)
        #expect(result?.suggestedWeightKg == 50)
        #expect(result?.suggestedReps == 7)
    }

    // MARK: - Rounding edge cases

    @Test("A very low weight rounds up to the absolute minimum of +0.5 kg")
    func minimumAbsoluteIncrease() {
        let planned = PlannedExercise(order: 0, repsMin: 8, repsMax: 10, rirTarget: 2)
        let lastSet = LoggedSet(order: 1, exerciseName: "Cable Curl", weightKg: 1.0, reps: 10, rirActual: 2)
        let result = ProgressiveOverloadSuggestion.suggest(lastSets: [lastSet], setNumber: 1, plannedExercise: planned, equipment: .machineOrCable)
        #expect(result?.suggestedWeightKg == 1.5)
    }
}

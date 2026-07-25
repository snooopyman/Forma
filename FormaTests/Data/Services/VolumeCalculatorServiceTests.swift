//
//  VolumeCalculatorServiceTests.swift
//  FormaTests
//
//  Created by Armando Cáceres on 25/7/26.
//

import Testing
import Foundation
@testable import Forma

@Suite("VolumeCalculatorService")
struct VolumeCalculatorServiceTests {
    
    let sut = VolumeCalculatorService()
    
    // MARK: - calculate(for session:)
    
    @Test("calculate(for session:) sums totals across all sets")
    func sessionTotals() {
        let session = makeSession(sets: [
            makeSet(muscle: .chest, weightKg: 100, reps: 10),
            makeSet(muscle: .back, weightKg: 50, reps: 8)
        ])
        let summary = sut.calculate(for: session)
        #expect(summary.totalSets == 2)
        #expect(summary.totalReps == 18)
        #expect(summary.totalVolume == 1400)
    }
    
    @Test("calculate(for session:) falls back to fullBody when exercise is missing")
    func sessionFallbackToFullBody() {
        let orphanSet = LoggedSet(order: 0, exerciseName: "Deleted exercise", weightKg: 20, reps: 10)
        let session = makeSession(sets: [orphanSet])
        let summary = sut.calculate(for: session)
        #expect(summary.volumeByMuscle[.fullBody]?.totalSets == 1)
        #expect(summary.volumeByMuscle[.chest] == nil)
    }
    
    @Test("calculate(for session:) duplicates .legs sets into quadriceps and hamstrings")
    func sessionLegsDuplication() {
        let legSet = makeSet(muscle: .legs, weightKg: 80, reps: 10)
        let session = makeSession(sets: [legSet])
        let summary = sut.calculate(for: session)
        
        #expect(summary.volumeByMuscle[.quadriceps]?.totalSets == 1)
        #expect(summary.volumeByMuscle[.hamstrings]?.totalSets == 1)
        #expect(summary.volumeByMuscle[.legs] == nil)
        // Totals are derived from the raw sets, not from the per-muscle breakdown — no double counting
        #expect(summary.totalSets == 1)
        #expect(summary.totalReps == 10)
        #expect(summary.totalVolume == 800)
    }
    
    @Test("calculate(for session:) does not fraction volume to secondary muscles")
    func sessionIgnoresSecondaryMuscles() {
        let exercise = Exercise(name: "Bench Press", primaryMuscle: .chest, secondaryMuscles: [.triceps, .shoulders])
        let planned = PlannedExercise(order: 0)
        planned.exercise = exercise
        let set = LoggedSet(order: 0, exerciseName: exercise.name, weightKg: 60, reps: 10)
        set.plannedExercise = planned
        let session = makeSession(sets: [set])
        
        let summary = sut.calculate(for: session)
        #expect(summary.volumeByMuscle[.chest]?.totalSets == 1)
        #expect(summary.volumeByMuscle[.triceps] == nil)
        #expect(summary.volumeByMuscle[.shoulders] == nil)
    }
    
    // MARK: - calculate(for sessions:)
    
    @Test("calculate(for sessions:) aggregates across multiple sessions")
    func weeklyAggregation() {
        let sessionA = makeSession(sets: [makeSet(muscle: .chest, weightKg: 100, reps: 10)])
        let sessionB = makeSession(sets: [makeSet(muscle: .chest, weightKg: 100, reps: 8)])
        let summary = sut.calculate(for: [sessionA, sessionB])
        #expect(summary.volumeByMuscle[.chest]?.totalSets == 2)
        #expect(summary.totalSets == 2)
        #expect(summary.totalReps == 18)
    }
    
    @Test("calculate(for sessions:) duplicates .legs sets into quadriceps and hamstrings")
    func weeklyLegsDuplication() {
        let session = makeSession(sets: [
            makeSet(muscle: .legs, weightKg: 80, reps: 10),
            makeSet(muscle: .legs, weightKg: 80, reps: 8)
        ])
        let summary = sut.calculate(for: [session])
        
        #expect(summary.volumeByMuscle[.quadriceps]?.totalSets == 2)
        #expect(summary.volumeByMuscle[.hamstrings]?.totalSets == 2)
        #expect(summary.volumeByMuscle[.legs] == nil)
        #expect(summary.totalSets == 2)
    }
    
    @Test("calculate(for sessions:) returns empty summary for no sessions")
    func weeklyEmpty() {
        let summary = sut.calculate(for: [])
        #expect(summary.totalSets == 0)
        #expect(summary.volumeByMuscle.isEmpty)
    }
}

// MARK: - Test Helpers

private extension VolumeCalculatorServiceTests {
    func makeSet(muscle: MuscleGroup, weightKg: Double, reps: Int) -> LoggedSet {
        let exercise = Exercise(name: "Exercise", primaryMuscle: muscle)
        let planned = PlannedExercise(order: 0)
        planned.exercise = exercise
        let set = LoggedSet(order: 0, exerciseName: exercise.name, weightKg: weightKg, reps: reps)
        set.plannedExercise = planned
        return set
    }
    
    func makeSession(sets: [LoggedSet]) -> WorkoutSession {
        let session = WorkoutSession()
        session.loggedSets = sets
        return session
    }
}

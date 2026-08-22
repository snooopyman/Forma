//
//  MesocycleComparisonTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 17/8/26.
//

import Testing
import Foundation
@testable import Forma

extension MesocycleComparisonTests {
    
    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {
        
        // MARK: - Subject Under Test
        
        let sut: MesocycleComparisonInteractor
        
        // MARK: - Initializers
        
        init() {
            sut = MesocycleComparisonInteractor(volumeCalculatorService: VolumeCalculatorService())
        }
        
        // MARK: - normalizationWeeks
        
        @Test("normalizationWeeks caps at durationWeeks for a mesocycle finished long ago")
        func normalizationWeeksCapsAtDuration() {
            let mesocycle = makeMesocycle(name: "Old", weeksAgo: 20, durationWeeks: 6)
            #expect(sut.normalizationWeeks(for: mesocycle) == 6)
        }
        
        @Test("normalizationWeeks reflects real elapsed weeks for an active mesocycle mid-block")
        func normalizationWeeksActiveMidBlock() {
            let mesocycle = makeMesocycle(name: "Active", weeksAgo: 3, durationWeeks: 8, isActive: true)
            #expect(sut.normalizationWeeks(for: mesocycle) == 4)
        }
        
        @Test("normalizationWeeks ignores pause state and does not collapse elapsed weeks to 1")
        func normalizationWeeksPausedMidBlock() {
            let mesocycle = makeMesocycle(name: "Paused", weeksAgo: 5, durationWeeks: 8)
            mesocycle.pausedAt = Calendar.current.date(byAdding: .day, value: -3, to: .now)
            #expect(mesocycle.isPaused == true)
            #expect(mesocycle.currentWeek == 0)
            
            #expect(sut.normalizationWeeks(for: mesocycle) == 6)
        }
        
        @Test("normalizationWeeks returns at least 1 week for a mesocycle starting today")
        func normalizationWeeksMinimumOneWeek() {
            let mesocycle = Mesocycle(name: "New", startDate: .now, durationWeeks: 6)
            #expect(sut.normalizationWeeks(for: mesocycle) == 1)
        }
        
        // MARK: - Adherence
        
        @Test("adherenceFraction computes completed over planned")
        func adherenceNormalCase() {
            let fraction = MesocycleComparisonEntry.adherenceFraction(completedSessions: 3, plannedSessions: 6)
            #expect(fraction == 0.5)
        }
        
        @Test("adherenceFraction returns nil, not NaN, when nothing was planned")
        func adherenceZeroPlanned() {
            let fraction = MesocycleComparisonEntry.adherenceFraction(completedSessions: 0, plannedSessions: 0)
            #expect(fraction == nil)
        }
        
        @Test("adherenceFraction is not clamped when completed sessions exceed planned ones")
        func adherenceExceedsPlanned() {
            let fraction = MesocycleComparisonEntry.adherenceFraction(completedSessions: 8, plannedSessions: 6)
            #expect(fraction != nil)
            #expect(abs((fraction ?? 0) - (8.0 / 6.0)) < 0.0001)
        }
        
        // MARK: - buildSnapshot
        
        @Test("buildSnapshot normalizes weekly volume across mesocycles of different durations")
        func buildSnapshotNormalizesAcrossDurations() {
            let short = makeMesocycle(name: "Short", weeksAgo: 10, durationWeeks: 4)
            short.sessions = [makeCompletedSession(sets: [makeSet(weightKg: 100, reps: 4)])]
            
            let long = makeMesocycle(name: "Long", weeksAgo: 20, durationWeeks: 8)
            long.sessions = [makeCompletedSession(sets: [makeSet(weightKg: 100, reps: 8)])]
            
            let snapshot = sut.buildSnapshot(for: [short, long])
            
            #expect(snapshot.entries.first { $0.name == "Short" }?.weeklyVolume == 100)
            #expect(snapshot.entries.first { $0.name == "Long" }?.weeklyVolume == 100)
        }
        
        @Test("buildSnapshot doesn't break the aggregate when one mesocycle has no logged sets")
        func buildSnapshotHandlesEmptyMesocycle() {
            let empty = makeMesocycle(name: "Empty", weeksAgo: 2, durationWeeks: 6)
            empty.sessions = [makeCompletedSession(sets: [])]
            
            let withData = makeMesocycle(name: "WithData", weeksAgo: 2, durationWeeks: 6)
            withData.sessions = [makeCompletedSession(sets: [makeSet(weightKg: 90, reps: 10)])]
            
            let snapshot = sut.buildSnapshot(for: [empty, withData])
            
            #expect(snapshot.entries.first { $0.name == "Empty" }?.weeklyVolume == 0)
            #expect(snapshot.entries.first { $0.name == "WithData" }?.weeklyVolume == 300)
        }
        
        @Test("buildSnapshot orders entries by startDate ascending regardless of input order")
        func buildSnapshotOrdersChronologically() {
            let oldest = makeMesocycle(name: "Oldest", weeksAgo: 10, durationWeeks: 4)
            let middle = makeMesocycle(name: "Middle", weeksAgo: 6, durationWeeks: 4)
            let newest = makeMesocycle(name: "Newest", weeksAgo: 2, durationWeeks: 4)
            for mesocycle in [oldest, middle, newest] {
                mesocycle.sessions = [makeCompletedSession(sets: [makeSet(weightKg: 50, reps: 10)])]
            }
            
            let snapshot = sut.buildSnapshot(for: [newest, oldest, middle])
            
            #expect(snapshot.entries.map(\.name) == ["Oldest", "Middle", "Newest"])
        }
        
        @Test("buildSnapshot derives planned sessions from non-rest workout days times normalization weeks")
        func buildSnapshotPlannedSessions() {
            let mesocycle = makeMesocycle(name: "Block", weeksAgo: 2, durationWeeks: 6)
            mesocycle.workoutDays = [
                WorkoutDay(name: "Push", order: 0),
                WorkoutDay(name: "Pull", order: 1),
                WorkoutDay(name: "Rest", order: 2, isRestDay: true)
            ]
            mesocycle.sessions = [makeCompletedSession(sets: [])]
            
            let snapshot = sut.buildSnapshot(for: [mesocycle])
            
            // weeksAgo: 2, durationWeeks: 6 -> normalizationWeeks == 3
            #expect(snapshot.entries.first?.plannedSessions == 6)
        }
    }
}

// MARK: - Test Helpers

private extension MesocycleComparisonTests.InteractorTests {
    func makeMesocycle(name: String, weeksAgo: Int, durationWeeks: Int, isActive: Bool = false) -> Mesocycle {
        Mesocycle(
            name: name,
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -weeksAgo, to: .now) ?? .now,
            durationWeeks: durationWeeks,
            isActive: isActive
        )
    }
    
    func makeSet(weightKg: Double, reps: Int, muscle: MuscleGroup = .chest) -> LoggedSet {
        let exercise = Exercise(name: "Exercise", primaryMuscle: muscle)
        let planned = PlannedExercise(order: 0)
        planned.exercise = exercise
        let set = LoggedSet(order: 0, exerciseName: exercise.name, weightKg: weightKg, reps: reps)
        set.plannedExercise = planned
        return set
    }
    
    func makeCompletedSession(sets: [LoggedSet]) -> WorkoutSession {
        let session = WorkoutSession()
        session.completedAt = .now
        session.loggedSets = sets
        return session
    }
}

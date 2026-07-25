//
//  WeeklyVolumeTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 25/7/26.
//

import Testing
import Foundation
@testable import Forma

extension WeeklyVolumeTests {
    
    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {
        
        // MARK: - Subject Under Test
        
        let sut: WeeklyVolumeInteractor
        
        // MARK: - Spies
        
        let sessionSpy: SpyWorkoutSessionRepository
        let targetSpy: SpyMuscleVolumeTargetRepository
        
        // MARK: - Initializers
        
        init() {
            sessionSpy = SpyWorkoutSessionRepository()
            targetSpy = SpyMuscleVolumeTargetRepository()
            sut = WeeklyVolumeInteractor(
                sessionRepository: sessionSpy,
                volumeCalculatorService: VolumeCalculatorService(),
                targetRepository: targetSpy
            )
        }
        
        // MARK: - loadSnapshot
        
        @Test("loadSnapshot() reports no completed sessions when the week is empty")
        func emptyWeek() async throws {
            sessionSpy.stubbedSessions = []
            targetSpy.stubbedTargets = makeAllTargets()
            let snapshot = try await sut.loadSnapshot()
            #expect(snapshot.hasCompletedSessionsThisWeek == false)
            #expect(snapshot.coachings.allSatisfy { $0.actualSets == 0 })
        }
        
        @Test("loadSnapshot() excludes sessions that are not completed")
        func excludesInProgressSessions() async throws {
            let inProgress = makeSession(muscle: .chest, isCompleted: false)
            sessionSpy.stubbedSessions = [inProgress]
            targetSpy.stubbedTargets = makeAllTargets()
            let snapshot = try await sut.loadSnapshot()
            #expect(snapshot.hasCompletedSessionsThisWeek == false)
            #expect(snapshot.coachings.first { $0.muscleGroup == .chest }?.actualSets == 0)
        }
        
        @Test("loadSnapshot() reports nil target/state for a muscle without a configured target")
        func missingTargetForMuscle() async throws {
            sessionSpy.stubbedSessions = [makeSession(muscle: .chest, isCompleted: true, sets: 5)]
            targetSpy.stubbedTargets = makeAllTargets().filter { $0.muscleGroup != .chest }
            let snapshot = try await sut.loadSnapshot()
            let chest = snapshot.coachings.first { $0.muscleGroup == .chest }
            #expect(chest?.target == nil)
            #expect(chest?.state == nil)
            #expect(chest?.actualSets == 5)
        }
        
        @Test("loadSnapshot() excludes cardio, fullBody and legs from the comparison")
        func excludesNonHypertrophyMuscles() async throws {
            targetSpy.stubbedTargets = makeAllTargets()
            let snapshot = try await sut.loadSnapshot()
            let muscles = Set(snapshot.coachings.map(\.muscleGroup))
            #expect(!muscles.contains(.cardio))
            #expect(!muscles.contains(.fullBody))
            #expect(!muscles.contains(.legs))
            #expect(muscles.count == 10)
        }
        
        @Test("loadSnapshot() classifies exactly at mevSets as optimal (closed lower bound)")
        func exactlyAtMev() async throws {
            sessionSpy.stubbedSessions = [makeSession(muscle: .chest, isCompleted: true, sets: 8)]
            targetSpy.stubbedTargets = [MuscleVolumeTarget(muscleGroup: .chest, mevSets: 8, mavSets: 16, mrvSets: 22)]
            let snapshot = try await sut.loadSnapshot()
            #expect(snapshot.coachings.first { $0.muscleGroup == .chest }?.state == .optimal)
        }
        
        @Test("loadSnapshot() classifies exactly at mrvSets as optimal (closed upper bound)")
        func exactlyAtMrv() async throws {
            sessionSpy.stubbedSessions = [makeSession(muscle: .chest, isCompleted: true, sets: 22)]
            targetSpy.stubbedTargets = [MuscleVolumeTarget(muscleGroup: .chest, mevSets: 8, mavSets: 16, mrvSets: 22)]
            let snapshot = try await sut.loadSnapshot()
            #expect(snapshot.coachings.first { $0.muscleGroup == .chest }?.state == .optimal)
        }
        
        @Test("loadSnapshot() classifies below mevSets as belowMinimum")
        func belowMev() async throws {
            sessionSpy.stubbedSessions = [makeSession(muscle: .chest, isCompleted: true, sets: 7)]
            targetSpy.stubbedTargets = [MuscleVolumeTarget(muscleGroup: .chest, mevSets: 8, mavSets: 16, mrvSets: 22)]
            let snapshot = try await sut.loadSnapshot()
            #expect(snapshot.coachings.first { $0.muscleGroup == .chest }?.state == .belowMinimum)
        }
        
        @Test("loadSnapshot() classifies above mrvSets as approachingMax")
        func aboveMrv() async throws {
            sessionSpy.stubbedSessions = [makeSession(muscle: .chest, isCompleted: true, sets: 23)]
            targetSpy.stubbedTargets = [MuscleVolumeTarget(muscleGroup: .chest, mevSets: 8, mavSets: 16, mrvSets: 22)]
            let snapshot = try await sut.loadSnapshot()
            #expect(snapshot.coachings.first { $0.muscleGroup == .chest }?.state == .approachingMax)
        }
        
        @Test("loadSnapshot() reports targets not configured below 13 entries")
        func targetsNotFullyConfigured() async throws {
            targetSpy.stubbedTargets = Array(makeAllTargets().prefix(12))
            let snapshot = try await sut.loadSnapshot()
            #expect(snapshot.hasTargetsConfigured == false)
        }
        
        @Test("loadSnapshot() reports targets configured at 13 entries")
        func targetsFullyConfigured() async throws {
            targetSpy.stubbedTargets = makeAllTargets()
            let snapshot = try await sut.loadSnapshot()
            #expect(snapshot.hasTargetsConfigured == true)
        }
        
        // MARK: - seedDefaultTargets
        
        @Test("seedDefaultTargets() creates one target per MuscleGroup case")
        func seedCreatesAll() async throws {
            try await sut.seedDefaultTargets()
            #expect(targetSpy.savedTargets.count == MuscleGroup.allCases.count)
        }
        
        @Test("seedDefaultTargets() rolls back created targets when an intermediate save fails")
        func seedRollsBackOnFailure() async throws {
            targetSpy.failOnSaveCount = 8
            targetSpy.errorToThrow = ProgressError.saveFailed
            await #expect(throws: ProgressError.self) {
                try await sut.seedDefaultTargets()
            }
            #expect(targetSpy.deletedTargets.count == 7)
        }
        
        // MARK: - restoreDefaultTargets
        
        @Test("restoreDefaultTargets() fills missing muscle groups without duplicating existing ones")
        func restoreFillsMissing() async throws {
            targetSpy.stubbedTargets = [MuscleVolumeTarget(muscleGroup: .chest, mevSets: 1, mavSets: 2, mrvSets: 3)]
            try await sut.restoreDefaultTargets()
            let savedMuscles = targetSpy.savedTargets.map(\.muscleGroup)
            #expect(Set(savedMuscles) == Set(MuscleGroup.allCases))
            #expect(savedMuscles.count == MuscleGroup.allCases.count)
        }
        
        @Test("restoreDefaultTargets() resets existing targets back to standard values")
        func restoreResetsExisting() async throws {
            let existing = MuscleVolumeTarget(muscleGroup: .chest, mevSets: 1, mavSets: 1, mrvSets: 1)
            targetSpy.stubbedTargets = [existing]
            try await sut.restoreDefaultTargets()
            #expect(existing.mevSets == MuscleVolumeStandards.values(for: .chest).mev)
            #expect(existing.mrvSets == MuscleVolumeStandards.values(for: .chest).mrv)
        }
    }
}

// MARK: - Test Helpers

private extension WeeklyVolumeTests.InteractorTests {
    func makeSession(muscle: MuscleGroup, isCompleted: Bool, sets: Int = 1) -> WorkoutSession {
        let session = WorkoutSession()
        let exercise = Exercise(name: "Exercise", primaryMuscle: muscle)
        let planned = PlannedExercise(order: 0)
        planned.exercise = exercise
        session.loggedSets = (0..<sets).map { i in
            let set = LoggedSet(order: i, exerciseName: exercise.name, weightKg: 20, reps: 10)
            set.plannedExercise = planned
            return set
        }
        if isCompleted {
            session.completedAt = .now
        }
        return session
    }
    
    func makeAllTargets() -> [MuscleVolumeTarget] {
        MuscleGroup.allCases.map { muscle in
            let standard = MuscleVolumeStandards.values(for: muscle)
            return MuscleVolumeTarget(muscleGroup: muscle, mevSets: standard.mev, mavSets: standard.mav, mrvSets: standard.mrv)
        }
    }
}

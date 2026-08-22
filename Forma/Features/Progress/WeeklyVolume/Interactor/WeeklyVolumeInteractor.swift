//
//  WeeklyVolumeInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import Foundation

final class WeeklyVolumeInteractor: WeeklyVolumeInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let sessionRepository: WorkoutSessionRepositoryProtocol
    private let volumeCalculatorService: VolumeCalculatorServiceProtocol
    private let targetRepository: MuscleVolumeTargetRepositoryProtocol
    
    // MARK: - Initializers
    
    init(
        sessionRepository: WorkoutSessionRepositoryProtocol,
        volumeCalculatorService: VolumeCalculatorServiceProtocol,
        targetRepository: MuscleVolumeTargetRepositoryProtocol
    ) {
        self.sessionRepository = sessionRepository
        self.volumeCalculatorService = volumeCalculatorService
        self.targetRepository = targetRepository
    }
    
    // MARK: - Functions
    
    func loadSnapshot() async throws -> WeeklyVolumeSnapshot {
        let weekRange = NaturalWeek.range(containing: .now)
        let sessions = try await sessionRepository.fetchAll(in: weekRange)
        let completedSessions = sessions.filter { $0.isCompleted }
        let weeklySummary = volumeCalculatorService.calculate(for: completedSessions)
        let targets = try await targetRepository.fetchAll()
        let targetsByMuscle = Dictionary(uniqueKeysWithValues: targets.map { ($0.muscleGroup, $0) })
        
        let coachings = MuscleGroup.comparable.map { muscle -> MuscleVolumeCoaching in
            let actualSets = weeklySummary.volumeByMuscle[muscle]?.totalSets ?? 0
            guard let target = targetsByMuscle[muscle] else {
                return MuscleVolumeCoaching(muscleGroup: muscle, actualSets: actualSets, target: nil, state: nil)
            }
            let values = MuscleVolumeTargetValues(mevSets: target.mevSets, mavSets: target.mavSets, mrvSets: target.mrvSets)
            return MuscleVolumeCoaching(
                muscleGroup: muscle,
                actualSets: actualSets,
                target: values,
                state: state(actualSets: actualSets, target: values)
            )
        }
        
        return WeeklyVolumeSnapshot(
            weekRange: weekRange,
            coachings: coachings,
            hasCompletedSessionsThisWeek: !completedSessions.isEmpty,
            hasTargetsConfigured: targets.count >= MuscleGroup.allCases.count
        )
    }
    
    func fetchTargets() async throws -> [MuscleVolumeTarget] {
        try await targetRepository.fetchAll()
    }
    
    func seedDefaultTargets() async throws {
        var created: [MuscleVolumeTarget] = []
        do {
            for muscle in MuscleGroup.allCases {
                let target = Self.makeStandardTarget(for: muscle)
                try await targetRepository.save(target)
                created.append(target)
            }
        } catch {
            for target in created {
                try? await targetRepository.delete(target)
            }
            throw error
        }
    }
    
    func restoreDefaultTargets() async throws {
        let existing = try await targetRepository.fetchAll()
        let existingByMuscle = Dictionary(uniqueKeysWithValues: existing.map { ($0.muscleGroup, $0) })
        
        for muscle in MuscleGroup.allCases {
            let standard = MuscleVolumeStandards.values(for: muscle)
            if let target = existingByMuscle[muscle] {
                target.mevSets = standard.mev
                target.mavSets = standard.mav
                target.mrvSets = standard.mrv
                try await targetRepository.save(target)
            } else {
                try await targetRepository.save(Self.makeStandardTarget(for: muscle))
            }
        }
    }
    
    func saveTarget(_ target: MuscleVolumeTarget) async throws {
        try await targetRepository.save(target)
    }
    
    // MARK: - Private Functions
    
    private func state(actualSets: Int, target: MuscleVolumeTargetValues) -> MuscleVolumeState {
        if actualSets < target.mevSets { return .belowMinimum }
        if actualSets > target.mrvSets { return .approachingMax }
        return .optimal
    }
    
    private static func makeStandardTarget(for muscle: MuscleGroup) -> MuscleVolumeTarget {
        let standard = MuscleVolumeStandards.values(for: muscle)
        return MuscleVolumeTarget(muscleGroup: muscle, mevSets: standard.mev, mavSets: standard.mav, mrvSets: standard.mrv)
    }
}

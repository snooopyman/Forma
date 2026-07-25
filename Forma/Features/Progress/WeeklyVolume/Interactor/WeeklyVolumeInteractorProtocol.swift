//
//  WeeklyVolumeInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import Foundation

enum MuscleVolumeState: Sendable {
    case belowMinimum
    case optimal
    case approachingMax
}

struct MuscleVolumeTargetValues: Sendable {
    let mevSets: Int
    let mavSets: Int
    let mrvSets: Int
}

struct MuscleVolumeCoaching: Sendable, Identifiable {
    let muscleGroup: MuscleGroup
    let actualSets: Int
    let target: MuscleVolumeTargetValues?
    let state: MuscleVolumeState?
    
    var id: MuscleGroup { muscleGroup }
}

struct WeeklyVolumeSnapshot: Sendable {
    let weekRange: Range<Date>
    let coachings: [MuscleVolumeCoaching]
    let hasCompletedSessionsThisWeek: Bool
    let hasTargetsConfigured: Bool
}

protocol WeeklyVolumeInteractorProtocol: Sendable {
    func loadSnapshot() async throws -> WeeklyVolumeSnapshot
    func fetchTargets() async throws -> [MuscleVolumeTarget]
    func seedDefaultTargets() async throws
    func restoreDefaultTargets() async throws
    func saveTarget(_ target: MuscleVolumeTarget) async throws
}

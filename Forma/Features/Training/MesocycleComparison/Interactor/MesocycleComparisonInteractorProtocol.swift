//
//  MesocycleComparisonInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 17/8/26.
//

import Foundation

struct MesocycleComparisonSnapshot {
    let entries: [MesocycleComparisonEntry]
}

struct MesocycleComparisonEntry: Identifiable {
    let mesocycle: Mesocycle
    let weeklyVolume: Double
    let volumeByMuscle: [MuscleGroup: Double]
    let completedSessions: Int
    let plannedSessions: Int
    
    var id: UUID { mesocycle.id }
    var name: String { mesocycle.name }
    var isInProgress: Bool { mesocycle.isActive }
    
    var adherenceFraction: Double? {
        Self.adherenceFraction(completedSessions: completedSessions, plannedSessions: plannedSessions)
    }
    
    static func adherenceFraction(completedSessions: Int, plannedSessions: Int) -> Double? {
        guard plannedSessions > 0 else { return nil }
        return Double(completedSessions) / Double(plannedSessions)
    }
}

protocol MesocycleComparisonInteractorProtocol: Sendable {
    func buildSnapshot(for mesocycles: [Mesocycle]) -> MesocycleComparisonSnapshot
}

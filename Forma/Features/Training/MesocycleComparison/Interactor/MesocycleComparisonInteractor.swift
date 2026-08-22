//
//  MesocycleComparisonInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 17/8/26.
//

import Foundation

final class MesocycleComparisonInteractor: MesocycleComparisonInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let volumeCalculatorService: VolumeCalculatorServiceProtocol
    
    // MARK: - Initializers
    
    init(volumeCalculatorService: VolumeCalculatorServiceProtocol) {
        self.volumeCalculatorService = volumeCalculatorService
    }
    
    // MARK: - Functions
    
    func buildSnapshot(for mesocycles: [Mesocycle]) -> MesocycleComparisonSnapshot {
        let ordered = mesocycles.sorted { $0.startDate < $1.startDate }
        return MesocycleComparisonSnapshot(entries: ordered.map(makeEntry))
    }
    
    func normalizationWeeks(for mesocycle: Mesocycle, referenceDate: Date = .now) -> Int {
        let calendar = Calendar.current
        let cappedReferenceDate = min(referenceDate, mesocycle.endDate)
        let weeksElapsed = calendar.dateComponents(
            [.weekOfYear],
            from: mesocycle.startDate,
            to: cappedReferenceDate
        ).weekOfYear ?? 0
        return min(mesocycle.durationWeeks, max(1, weeksElapsed + 1))
    }
    
    // MARK: - Private Functions
    
    private func makeEntry(for mesocycle: Mesocycle) -> MesocycleComparisonEntry {
        let weeks = normalizationWeeks(for: mesocycle)
        let completedSessions = mesocycle.sessions.filter { $0.isCompleted }
        let weeklySummary = volumeCalculatorService.calculate(for: completedSessions)
        let volumeByMuscle = Dictionary(uniqueKeysWithValues: MuscleGroup.comparable.map { muscle in
            (muscle, Double(weeklySummary.volumeByMuscle[muscle]?.totalSets ?? 0) / Double(weeks))
        })
        let nonRestDays = mesocycle.workoutDays.filter { !$0.isRestDay }.count
        
        return MesocycleComparisonEntry(
            mesocycle: mesocycle,
            weeklyVolume: weeklySummary.totalVolume / Double(weeks),
            volumeByMuscle: volumeByMuscle,
            completedSessions: completedSessions.count,
            plannedSessions: nonRestDays * weeks
        )
    }
}

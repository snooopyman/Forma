//
//  VolumeCalculatorService.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation

struct MuscleVolumeSummary: Sendable {
    let muscleGroup: MuscleGroup
    let totalSets: Int
    let totalReps: Int
    let totalVolume: Double
}

struct SessionVolumeSummary: Sendable {
    let totalSets: Int
    let totalReps: Int
    let totalVolume: Double
    let duration: TimeInterval?
    let volumeByMuscle: [MuscleGroup: MuscleVolumeSummary]
    
    var durationFormatted: String {
        guard let duration else { return "--" }
        return Duration.seconds(Int(duration)).formatted(.time(pattern: .minuteSecond))
    }
}

struct WeeklyVolumeSummary: Sendable {
    let totalSets: Int
    let totalReps: Int
    let totalVolume: Double
    let volumeByMuscle: [MuscleGroup: MuscleVolumeSummary]
}

protocol VolumeCalculatorServiceProtocol: Sendable {
    func calculate(for session: WorkoutSession) -> SessionVolumeSummary
    func calculate(for sessions: [WorkoutSession]) -> WeeklyVolumeSummary
}

struct VolumeCalculatorService: VolumeCalculatorServiceProtocol {
    
    func calculate(for session: WorkoutSession) -> SessionVolumeSummary {
        let sets = session.loggedSets
        return SessionVolumeSummary(
            totalSets: sets.count,
            totalReps: sets.reduce(0) { $0 + $1.reps },
            totalVolume: sets.reduce(0.0) { $0 + ($1.weightKg * Double($1.reps)) },
            duration: session.duration,
            volumeByMuscle: volumeByMuscle(for: sets)
        )
    }
    
    func calculate(for sessions: [WorkoutSession]) -> WeeklyVolumeSummary {
        let sets = sessions.flatMap { $0.loggedSets }
        return WeeklyVolumeSummary(
            totalSets: sets.count,
            totalReps: sets.reduce(0) { $0 + $1.reps },
            totalVolume: sets.reduce(0.0) { $0 + ($1.weightKg * Double($1.reps)) },
            volumeByMuscle: volumeByMuscle(for: sets)
        )
    }
    
    // MARK: - Private Functions
    
    private func volumeByMuscle(for sets: [LoggedSet]) -> [MuscleGroup: MuscleVolumeSummary] {
        groupByMuscle(sets).reduce(into: [:]) { result, entry in
            let (muscle, muscleSets) = entry
            result[muscle] = MuscleVolumeSummary(
                muscleGroup: muscle,
                totalSets: muscleSets.count,
                totalReps: muscleSets.reduce(0) { $0 + $1.reps },
                totalVolume: muscleSets.reduce(0.0) { $0 + ($1.weightKg * Double($1.reps)) }
            )
        }
    }
    
    private func groupByMuscle(_ sets: [LoggedSet]) -> [MuscleGroup: [LoggedSet]] {
        var grouped: [MuscleGroup: [LoggedSet]] = [:]
        for set in sets {
            let muscle = set.plannedExercise?.exercise?.primaryMuscle ?? .fullBody
            if muscle == .legs {
                grouped[.quadriceps, default: []].append(set)
                grouped[.hamstrings, default: []].append(set)
            } else {
                grouped[muscle, default: []].append(set)
            }
        }
        return grouped
    }
}

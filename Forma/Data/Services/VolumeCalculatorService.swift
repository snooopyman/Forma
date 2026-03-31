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

protocol VolumeCalculatorServiceProtocol: Sendable {
    func calculate(for session: WorkoutSession) -> SessionVolumeSummary
}

struct VolumeCalculatorService: VolumeCalculatorServiceProtocol {

    func calculate(for session: WorkoutSession) -> SessionVolumeSummary {
        let sets = session.loggedSets
        let totalSets = sets.count
        let totalReps = sets.reduce(0) { $0 + $1.reps }
        let totalVolume = sets.reduce(0.0) { $0 + ($1.weightKg * Double($1.reps)) }

        var grouped: [MuscleGroup: [LoggedSet]] = [:]
        for set in sets {
            let muscle = set.plannedExercise?.exercise?.primaryMuscle ?? .fullBody
            grouped[muscle, default: []].append(set)
        }

        let volumeByMuscle = grouped.mapValues { muscleSets -> MuscleVolumeSummary in
            let muscle = muscleSets.first?.plannedExercise?.exercise?.primaryMuscle ?? .fullBody
            return MuscleVolumeSummary(
                muscleGroup: muscle,
                totalSets: muscleSets.count,
                totalReps: muscleSets.reduce(0) { $0 + $1.reps },
                totalVolume: muscleSets.reduce(0.0) { $0 + ($1.weightKg * Double($1.reps)) }
            )
        }

        return SessionVolumeSummary(
            totalSets: totalSets,
            totalReps: totalReps,
            totalVolume: totalVolume,
            duration: session.duration,
            volumeByMuscle: volumeByMuscle
        )
    }
}

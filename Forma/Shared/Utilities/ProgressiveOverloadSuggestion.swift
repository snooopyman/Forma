//
//  ProgressiveOverloadSuggestion.swift
//  Forma
//
//  Created by Armando Cáceres on 10/7/26.
//

import Foundation

enum ProgressiveOverloadSuggestion {
    
    // MARK: - Functions
    
    static func referenceSet(from lastSets: [LoggedSet], setNumber: Int) -> LoggedSet? {
        guard !lastSets.isEmpty else { return nil }
        return setNumber <= lastSets.count ? lastSets[setNumber - 1] : lastSets.last
    }
    
    static func suggest(
        lastSets: [LoggedSet],
        setNumber: Int,
        plannedExercise: PlannedExercise,
        equipment: EquipmentType?
    ) -> (suggestedWeightKg: Double, suggestedReps: Int)? {
        guard let refSet = referenceSet(from: lastSets, setNumber: setNumber) else { return nil }
        
        let repsMax = plannedExercise.repsMax
        let reachedRepsMax = refSet.reps >= repsMax
        let rirMet = refSet.rirActual == nil || refSet.rirActual! >= plannedExercise.rirTarget
        let isUnloadedBodyweight = equipment == .bodyweight && refSet.weightKg == 0
        
        if reachedRepsMax && rirMet && !isUnloadedBodyweight {
            return (increasedWeight(from: refSet.weightKg, equipment: equipment), plannedExercise.repsMin)
        }
        
        if !reachedRepsMax || isUnloadedBodyweight {
            return (refSet.weightKg, min(refSet.reps + 1, repsMax))
        }
        
        return (refSet.weightKg, repsMax)
    }
    
    // MARK: - Private Functions
    
    private static func increasedWeight(from weightKg: Double, equipment: EquipmentType?) -> Double {
        let increment = equipment == .dumbbell ? 0.05 : 0.025
        let raw = weightKg * (1 + increment)
        let rounded = ((raw / 0.5) + 1e-9).rounded() * 0.5
        let minimumIncrease = weightKg + 0.5
        return max(rounded, minimumIncrease)
    }
}

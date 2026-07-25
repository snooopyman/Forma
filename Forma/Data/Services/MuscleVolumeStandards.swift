//
//  MuscleVolumeStandards.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import Foundation

enum MuscleVolumeStandards {
    
    static func values(for muscleGroup: MuscleGroup) -> (mev: Int, mav: Int, mrv: Int) {
        switch muscleGroup {
        case .chest:      return (8, 16, 22)
        case .back:       return (10, 18, 25)
        case .shoulders:  return (8, 18, 26)
        case .biceps:     return (6, 16, 26)
        case .triceps:    return (6, 12, 18)
        case .quadriceps: return (8, 14, 20)
        case .hamstrings: return (6, 12, 20)
        case .glutes:     return (4, 10, 16)
        case .calves:     return (8, 14, 20)
        case .core:       return (6, 14, 20)
        case .legs, .cardio, .fullBody: return (0, 0, 0)
        }
    }
}

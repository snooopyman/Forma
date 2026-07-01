//
//  MuscleGroup.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

enum MuscleGroup: String, CaseIterable, Codable {
    case chest
    case back
    case legs
    case quadriceps
    case hamstrings
    case shoulders
    case biceps
    case triceps
    case core
    case glutes
    case calves
    case cardio
    case fullBody = "fullbody"
    
    var color: Color {
        switch self {
        case .chest:                    return .muscleChest
        case .back:                     return .muscleBack
        case .legs, .quadriceps,
                .hamstrings:              return .muscleLegs
        case .shoulders:                return .muscleShoulders
        case .biceps:                   return .muscleBiceps
        case .triceps:                  return .muscleTriceps
        case .core:                     return .muscleCore
        case .glutes:                   return .muscleGlutes
        case .calves:                   return .muscleCalves
        case .cardio, .fullBody:        return .muscleCardio
        }
    }
    
    var localizedName: String {
        switch self {
        case .chest:        return String(localized: "Chest")
        case .back:         return String(localized: "Back")
        case .legs:         return String(localized: "Legs")
        case .quadriceps:   return String(localized: "Quads")
        case .hamstrings:   return String(localized: "Hamstrings")
        case .shoulders:    return String(localized: "Shoulders")
        case .biceps:       return String(localized: "Biceps")
        case .triceps:      return String(localized: "Triceps")
        case .core:         return String(localized: "Core")
        case .glutes:       return String(localized: "Glutes")
        case .calves:       return String(localized: "Calves")
        case .cardio:       return String(localized: "Cardio")
        case .fullBody:     return String(localized: "Full Body")
        }
    }
}

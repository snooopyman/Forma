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
        case .chest:                    return .blue
        case .back:                     return .green
        case .legs, .quadriceps,
             .hamstrings:              return .red
        case .shoulders:                return .purple
        case .biceps:                   return .orange
        case .triceps:                  return .yellow
        case .core:                     return .teal
        case .glutes:                   return .pink
        case .calves:                   return .brown
        case .cardio, .fullBody:        return .cyan
        }
    }

    var localizedName: String {
        switch self {
        case .chest:        return "Chest"
        case .back:         return "Back"
        case .legs:         return "Legs"
        case .quadriceps:   return "Quads"
        case .hamstrings:   return "Hamstrings"
        case .shoulders:    return "Shoulders"
        case .biceps:       return "Biceps"
        case .triceps:      return "Triceps"
        case .core:         return "Core"
        case .glutes:       return "Glutes"
        case .calves:       return "Calves"
        case .cardio:       return "Cardio"
        case .fullBody:     return "Full Body"
        }
    }
}

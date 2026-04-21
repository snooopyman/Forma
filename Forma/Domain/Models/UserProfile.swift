//
//  UserProfile.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class UserProfile {

    var id: UUID
    var name: String
    var birthDate: Date
    var heightCm: Double
    var biologicalSex: BiologicalSex
    var activityLevel: ActivityLevel
    var weightUnit: WeightUnit
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        heightCm: Double,
        biologicalSex: BiologicalSex,
        activityLevel: ActivityLevel = .moderatelyActive,
        weightUnit: WeightUnit = .kg,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.heightCm = heightCm
        self.biologicalSex = biologicalSex
        self.activityLevel = activityLevel
        self.weightUnit = weightUnit
        self.createdAt = createdAt
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: .now).year ?? 0
    }
}

enum BiologicalSex: String, Codable, CaseIterable {
    case male
    case female

    var localizedName: String {
        switch self {
        case .male:   return String(localized: "Male")
        case .female: return String(localized: "Female")
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary
    case lightlyActive
    case moderatelyActive
    case veryActive
    case extraActive

    var localizedName: String {
        switch self {
        case .sedentary:        return String(localized: "Sedentary")
        case .lightlyActive:    return String(localized: "Lightly active")
        case .moderatelyActive: return String(localized: "Moderately active")
        case .veryActive:       return String(localized: "Very active")
        case .extraActive:      return String(localized: "Extra active")
        }
    }

    var description: String {
        switch self {
        case .sedentary:        return String(localized: "Little or no exercise")
        case .lightlyActive:    return String(localized: "Light exercise 1–3 days/week")
        case .moderatelyActive: return String(localized: "Moderate exercise 3–5 days/week")
        case .veryActive:       return String(localized: "Hard exercise 6–7 days/week")
        case .extraActive:      return String(localized: "Very hard exercise or physical job")
        }
    }

    // Multiplier Harris-Benedict
    var tdeeMultiplier: Double {
        switch self {
        case .sedentary:        return 1.2
        case .lightlyActive:    return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive:       return 1.725
        case .extraActive:      return 1.9
        }
    }
}

enum WeightUnit: String, Codable, CaseIterable {
    case kg
    case lbs

    var localizedName: String {
        switch self {
        case .kg:  return "kg"
        case .lbs: return "lbs"
        }
    }

    func convert(_ value: Double, to target: WeightUnit) -> Double {
        guard self != target else { return value }
        return self == .kg ? value * 2.20462 : value / 2.20462
    }
}

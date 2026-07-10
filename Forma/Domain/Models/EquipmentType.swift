//
//  EquipmentType.swift
//  Forma
//
//  Created by Armando Cáceres on 10/7/26.
//

import Foundation

enum EquipmentType: String, CaseIterable, Codable {
    case barbell
    case dumbbell
    case machineOrCable
    case bodyweight

    var localizedName: String {
        switch self {
        case .barbell:        return String(localized: "Barbell")
        case .dumbbell:       return String(localized: "Dumbbell")
        case .machineOrCable: return String(localized: "Machine / Cable")
        case .bodyweight:     return String(localized: "Bodyweight")
        }
    }
}

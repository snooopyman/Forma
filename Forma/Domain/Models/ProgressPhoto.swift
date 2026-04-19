//
//  ProgressPhoto.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class ProgressPhoto {

    var id: UUID
    var date: Date
    var angle: PhotoAngle
    var notes: String

    @Attribute(.externalStorage)
    var imageData: Data

    init(
        id: UUID = UUID(),
        date: Date = .now,
        angle: PhotoAngle,
        imageData: Data,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.angle = angle
        self.imageData = imageData
        self.notes = notes
    }
}

enum PhotoAngle: String, Codable, CaseIterable {
    case front
    case sideLeft
    case sideRight
    case back

    var localizedName: String {
        switch self {
        case .front:     return String(localized: "Front")
        case .sideLeft:  return String(localized: "Side left")
        case .sideRight: return String(localized: "Side right")
        case .back:      return String(localized: "Back")
        }
    }

    var sortOrder: Int {
        switch self {
        case .front:     return 0
        case .back:      return 1
        case .sideLeft:  return 2
        case .sideRight: return 3
        }
    }
}

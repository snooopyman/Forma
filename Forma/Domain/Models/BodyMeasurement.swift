//
//  BodyMeasurement.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class BodyMeasurement {

    var id: UUID
    var date: Date
    var weightKg: Double
    var neckCm: Double?
    var armCm: Double?
    var waistCm: Double?
    var abdomenCm: Double?
    var pelvisCm: Double?
    var thighCm: Double?
    var notes: String

    // Snapshot of user profile at the time of measurement, required for formula calculations
    var heightCm: Double
    var biologicalSex: BiologicalSex

    init(
        id: UUID = UUID(),
        date: Date = .now,
        weightKg: Double,
        heightCm: Double,
        biologicalSex: BiologicalSex,
        neckCm: Double? = nil,
        armCm: Double? = nil,
        waistCm: Double? = nil,
        abdomenCm: Double? = nil,
        pelvisCm: Double? = nil,
        thighCm: Double? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.biologicalSex = biologicalSex
        self.neckCm = neckCm
        self.armCm = armCm
        self.waistCm = waistCm
        self.abdomenCm = abdomenCm
        self.pelvisCm = pelvisCm
        self.thighCm = thighCm
        self.notes = notes
    }

    // US Navy formula (ADR-006): 86.010 × log10(abdomen − neck) − 70.041 × log10(height) + 36.76
    var bodyFatPercent: Double? {
        guard let neck = neckCm, let abdomen = abdomenCm,
              neck > 0, abdomen > neck, heightCm > 0 else { return nil }
        return 86.010 * log10(abdomen - neck) - 70.041 * log10(heightCm) + 36.76
    }

    var bmi: Double? {
        guard weightKg > 0, heightCm > 0 else { return nil }
        let heightM = heightCm / 100
        return weightKg / (heightM * heightM)
    }
}

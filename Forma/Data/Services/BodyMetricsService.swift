//
//  BodyMetricsService.swift
//  Forma
//
//  Created by Armando Cáceres on 1/4/26.
//

import Foundation

// MARK: - BMICategory

enum BMICategory: Sendable {
    case underweight
    case normal
    case overweight
    case obese

    var localizedName: String {
        switch self {
        case .underweight: String(localized: "Underweight")
        case .normal:      String(localized: "Normal")
        case .overweight:  String(localized: "Overweight")
        case .obese:       String(localized: "Obese")
        }
    }
}

// MARK: - BodyFatCategory

enum BodyFatCategory: Sendable {
    case essentialFat
    case athletic
    case fitness
    case average
    case aboveAverage

    var localizedName: String {
        switch self {
        case .essentialFat: String(localized: "Essential fat")
        case .athletic:     String(localized: "Athletic")
        case .fitness:      String(localized: "Fitness")
        case .average:      String(localized: "Average")
        case .aboveAverage: String(localized: "Above average")
        }
    }
}

// MARK: - Protocol

protocol BodyMetricsServiceProtocol: Sendable {
    func bmiCategory(for bmi: Double) -> BMICategory
    func bodyFatCategory(for bodyFat: Double, sex: BiologicalSex) -> BodyFatCategory
}

// MARK: - Implementation

struct BodyMetricsService: BodyMetricsServiceProtocol {

    func bmiCategory(for bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5:   .underweight
        case 18.5..<25: .normal
        case 25..<30:   .overweight
        default:        .obese
        }
    }

    // ACE body fat percentage classification
    func bodyFatCategory(for bodyFat: Double, sex: BiologicalSex) -> BodyFatCategory {
        switch sex {
        case .male:
            switch bodyFat {
            case ..<6:    .essentialFat
            case 6..<14:  .athletic
            case 14..<18: .fitness
            case 18..<25: .average
            default:      .aboveAverage
            }
        case .female:
            switch bodyFat {
            case ..<14:   .essentialFat
            case 14..<21: .athletic
            case 21..<25: .fitness
            case 25..<32: .average
            default:      .aboveAverage
            }
        }
    }
}

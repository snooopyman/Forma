//
//  NutritionError.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

enum NutritionError: LocalizedError, Equatable {
    case loadFailed
    case saveFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .loadFailed:   L10n.Nutrition.Error.loadFailed
        case .saveFailed:   L10n.Nutrition.Error.saveFailed
        case .deleteFailed: L10n.Nutrition.Error.deleteFailed
        }
    }
}

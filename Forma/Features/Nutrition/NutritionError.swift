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
        case .loadFailed:   String(localized: "Could not load nutrition data")
        case .saveFailed:   String(localized: "Could not save changes")
        case .deleteFailed: String(localized: "Could not delete item")
        }
    }
}

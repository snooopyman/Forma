//
//  TrainingError.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

enum TrainingError: LocalizedError, Equatable {
    case loadFailed
    case saveFailed
    case deleteFailed
    case setActiveFailed
    case sessionNotFound
    case logSetFailed
    case finishFailed
    
    var errorDescription: String? {
        switch self {
        case .loadFailed:      String(localized: "Could not load training data")
        case .saveFailed:      String(localized: "Could not save changes")
        case .deleteFailed:    String(localized: "Could not delete item")
        case .setActiveFailed: String(localized: "Could not set active mesocycle")
        case .sessionNotFound: String(localized: "Session not found")
        case .logSetFailed:    String(localized: "Could not log set")
        case .finishFailed:    String(localized: "Could not finish session")
        }
    }
}

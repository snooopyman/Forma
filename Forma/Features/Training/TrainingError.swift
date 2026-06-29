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
        case .loadFailed:      return L10n.Training.Error.loadFailed
        case .saveFailed:      return L10n.Training.Error.saveFailed
        case .deleteFailed:    return L10n.Training.Error.deleteFailed
        case .setActiveFailed: return L10n.Training.Error.setActiveFailed
        case .sessionNotFound: return L10n.Training.Error.sessionNotFound
        case .logSetFailed:    return L10n.Training.Error.logSetFailed
        case .finishFailed:    return L10n.Training.Error.finishFailed
        }
    }
}

//
//  ProgressError.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

enum ProgressError: LocalizedError, Equatable {
    case loadFailed
    case saveFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .loadFailed:   L10n.Progress.Error.loadFailed
        case .saveFailed:   L10n.Progress.Error.saveFailed
        case .deleteFailed: L10n.Progress.Error.deleteFailed
        }
    }
}

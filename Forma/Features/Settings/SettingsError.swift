//
//  SettingsError.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

enum SettingsError: LocalizedError, Equatable {
    case loadFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .loadFailed: L10n.Settings.Error.loadFailed
        case .saveFailed: L10n.Settings.Error.saveFailed
        }
    }
}

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
        case .loadFailed: String(localized: "Could not load profile")
        case .saveFailed: String(localized: "Could not save profile")
        }
    }
}

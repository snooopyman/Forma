//
//  SettingsInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol SettingsInteractorProtocol: Sendable {
    func loadProfile() async throws -> UserProfile?
    func requestHealthKitAccess() async throws
}

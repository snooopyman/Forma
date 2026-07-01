//
//  SettingsInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol SettingsInteractorProtocol: Sendable {
    var isHealthKitAvailable: Bool { get }
    var isHealthKitAuthorized: Bool { get }
    func loadProfile() async throws -> UserProfile?
    func requestHealthKitAccess() async throws
}

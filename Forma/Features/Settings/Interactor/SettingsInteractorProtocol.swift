//
//  SettingsInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation
import UserNotifications

protocol SettingsInteractorProtocol: Sendable {
    var isHealthKitAvailable: Bool { get }
    var isHealthKitAuthorized: Bool { get }
    func loadProfile() async throws -> UserProfile?
    func requestHealthKitAccess() async throws

    func notificationAuthorizationStatus() async -> UNAuthorizationStatus
    func requestNotificationAccess() async throws -> Bool
    func saveNotificationPreference(_ profile: UserProfile) async throws
}

//
//  SettingsViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 27/4/26.
//

import Foundation
import CloudKit
import OSLog
import SwiftUI
import UserNotifications

@Observable
@MainActor
final class SettingsViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: SettingsInteractorProtocol
    
    // MARK: - States
    
    var profile: UserProfile?
    var cloudKitStatus: CKAccountStatus = .couldNotDetermine
    var isRequestingHealthKit = false
    var healthKitError: String?
    var exportFileURL: URL?
    var exportError: String?
    
    var notificationsEnabled = false
    var reminderWeekday: Weekday = .saturday
    var reminderHour = 9
    var reminderMinute = 0
    var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    var isRequestingNotifications = false
    var notificationError: String?
    var showNotificationSystemSettingsAlert = false
    
    // MARK: - Computed Properties
    
    var isHealthKitAvailable: Bool { interactor.isHealthKitAvailable }
    var isHealthKitAuthorized: Bool { interactor.isHealthKitAuthorized }
    
    var cloudKitStatusText: String {
        switch cloudKitStatus {
        case .available:              return L10n.Settings.ICloud.syncing
        case .noAccount:              return L10n.Settings.ICloud.noAccount
        case .restricted:             return L10n.Settings.ICloud.restricted
        case .temporarilyUnavailable: return L10n.Settings.ICloud.temporarilyUnavailable
        case .couldNotDetermine:      return L10n.Settings.ICloud.checking
        @unknown default:             return L10n.Settings.ICloud.unknown
        }
    }
    
    var cloudKitStatusIconName: String {
        switch cloudKitStatus {
        case .available:              return "checkmark.icloud.fill"
        case .noAccount:              return "icloud.slash.fill"
        case .restricted:             return "exclamationmark.icloud.fill"
        case .temporarilyUnavailable: return "exclamationmark.icloud.fill"
        default:                      return "icloud.fill"
        }
    }
    
    var cloudKitStatusColor: Color {
        switch cloudKitStatus {
        case .available:                            return .success
        case .noAccount, .couldNotDetermine:        return .textSecondary
        case .restricted, .temporarilyUnavailable:  return .error
        @unknown default:                           return .textSecondary
        }
    }
    
    var appVersion: String { Bundle.appVersion }
    
    var reminderTime: Date {
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        return Calendar.current.date(from: components) ?? .now
    }
    
    // MARK: - Initializers
    
    init(interactor: SettingsInteractorProtocol) {
        self.interactor = interactor
    }
    
    // MARK: - Functions
    
    func load() async {
        profile = try? await interactor.loadProfile()
        buildExportJSON()
        checkCloudKitStatus()
        await syncNotificationState()
    }
    
    func refreshNotificationAuthorization() async {
        await syncNotificationState()
    }
    
    func requestHealthKitAccess() async {
        isRequestingHealthKit = true
        defer { isRequestingHealthKit = false }
        do {
            try await interactor.requestHealthKitAccess()
        } catch {
            handleError(error)
        }
    }
    
    func setNotificationsEnabled(_ enabled: Bool) async {
        guard let profile else { return }
        if enabled {
            isRequestingNotifications = true
            defer { isRequestingNotifications = false }
            
            switch notificationAuthorizationStatus {
            case .denied:
                showNotificationSystemSettingsAlert = true
                return
            case .authorized, .provisional, .ephemeral:
                break
            default:
                do {
                    let granted = try await interactor.requestNotificationAccess()
                    notificationAuthorizationStatus = granted ? .authorized : .denied
                    guard granted else { return }
                } catch {
                    handleNotificationError(error)
                    return
                }
            }
        }
        
        profile.notificationsEnabled = enabled
        notificationsEnabled = enabled
        await persistNotificationPreference()
    }
    
    func updateReminderWeekday(_ weekday: Weekday) async {
        guard let profile else { return }
        profile.reminderWeekday = weekday
        reminderWeekday = weekday
        await persistNotificationPreference()
    }
    
    func updateReminderTime(hour: Int, minute: Int) async {
        guard let profile else { return }
        profile.reminderHour = hour
        profile.reminderMinute = minute
        reminderHour = hour
        reminderMinute = minute
        await persistNotificationPreference()
    }
    
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Private Functions
    
    private func syncNotificationState() async {
        notificationAuthorizationStatus = await interactor.notificationAuthorizationStatus()
        guard let profile else { return }
        
        if profile.notificationsEnabled, notificationAuthorizationStatus != .authorized {
            profile.notificationsEnabled = false
            await persistNotificationPreference()
        }
        
        notificationsEnabled = profile.notificationsEnabled
        reminderWeekday = profile.reminderWeekday ?? .saturday
        reminderHour = profile.reminderHour
        reminderMinute = profile.reminderMinute
    }
    
    private func persistNotificationPreference() async {
        guard let profile else { return }
        do {
            try await interactor.saveNotificationPreference(profile)
        } catch {
            handleNotificationError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        Logger.healthKit.error("Error: \(error, privacy: .private)")
        if let settingsError = error as? SettingsError {
            healthKitError = settingsError.errorDescription
        } else {
            healthKitError = error.localizedDescription
        }
    }
    
    private func handleNotificationError(_ error: Error) {
        Logger.notifications.error("Error: \(error, privacy: .private)")
        if let settingsError = error as? SettingsError {
            notificationError = settingsError.errorDescription
        } else {
            notificationError = error.localizedDescription
        }
    }
    
    private func buildExportJSON() {
        guard let profile else { return }
        let dto = ProfileExportDTO(
            name: profile.name,
            birthDate: profile.birthDate.formatted(date: .abbreviated, time: .omitted),
            age: profile.age,
            heightCm: profile.heightCm,
            biologicalSex: profile.biologicalSex.rawValue,
            activityLevel: profile.activityLevel.rawValue,
            weightUnit: profile.weightUnit.rawValue,
            exportedAt: Date.now.formatted()
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("forma-profile.json")
        do {
            let data = try encoder.encode(dto)
            try data.write(to: url)
            exportFileURL = url
        } catch {
            Logger.core.error("Profile export failed: \(error, privacy: .public)")
            exportError = L10n.Settings.Error.exportFailed
        }
    }
    
    private func checkCloudKitStatus() {
        cloudKitStatus = FileManager.default.ubiquityIdentityToken != nil ? .available : .noAccount
    }
}

// MARK: - Export DTO

private struct ProfileExportDTO: Encodable {
    let name: String
    let birthDate: String
    let age: Int
    let heightCm: Double
    let biologicalSex: String
    let activityLevel: String
    let weightUnit: String
    let exportedAt: String
}

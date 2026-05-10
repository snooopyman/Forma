//
//  SettingsViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 27/4/26.
//

import Foundation
import CloudKit
import OSLog

@Observable
@MainActor
final class SettingsViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let healthKitService: HealthKitServiceProtocol

    // MARK: - States

    var profile: UserProfile?
    var cloudKitStatus: CKAccountStatus = .couldNotDetermine
    var isRequestingHealthKit = false
    var healthKitError: String?
    var exportJSON: String?

    // MARK: - Computed Properties

    var isHealthKitAvailable: Bool { healthKitService.isAvailable }

    var cloudKitStatusText: String {
        switch cloudKitStatus {
        case .available:              return String(localized: "Syncing with iCloud")
        case .noAccount:              return String(localized: "No iCloud account")
        case .restricted:             return String(localized: "iCloud restricted")
        case .temporarilyUnavailable: return String(localized: "Temporarily unavailable")
        case .couldNotDetermine:      return String(localized: "Checking…")
        @unknown default:             return String(localized: "Unknown")
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

    var cloudKitIsHealthy: Bool { cloudKitStatus == .available }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // MARK: - Initializers

    init(healthKitService: HealthKitServiceProtocol) {
        self.healthKitService = healthKitService
    }

    // MARK: - Functions

    func load(userProfileRepository: UserProfileRepositoryProtocol) async {
        profile = try? await userProfileRepository.fetch()
        buildExportJSON()
        await checkCloudKitStatus()
    }

    func requestHealthKitAccess() async {
        isRequestingHealthKit = true
        defer { isRequestingHealthKit = false }
        do {
            try await healthKitService.requestAuthorization()
        } catch {
            healthKitError = error.localizedDescription
            Logger.healthKit.error("HealthKit auth error: \(error, privacy: .private)")
        }
    }

    // MARK: - Private Functions

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
        guard let data = try? encoder.encode(dto),
              let json = String(data: data, encoding: .utf8) else { return }
        exportJSON = json
    }

    private func checkCloudKitStatus() async {
        #if targetEnvironment(simulator)
        cloudKitStatus = .noAccount
        #else
        do {
            cloudKitStatus = try await CKContainer(identifier: "iCloud.com.armando.forma").accountStatus()
        } catch {
            Logger.sync.error("CloudKit status check failed: \(error, privacy: .private)")
        }
        #endif
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

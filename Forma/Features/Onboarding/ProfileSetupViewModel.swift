//
//  ProfileSetupViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 20/4/26.
//

import SwiftUI
import OSLog

@MainActor
@Observable
final class ProfileSetupViewModel {

    // MARK: - States

    var name = ""
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: .now) ?? .now
    var heightCm: Double = 170
    var biologicalSex: BiologicalSex = .male
    var activityLevel: ActivityLevel = .moderatelyActive
    var currentStep = 0
    var isSaving = false

    // MARK: - Computed Properties

    var canAdvanceFromName: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Private Properties

    private let repository: UserProfileRepositoryProtocol
    private let healthKitService: HealthKitServiceProtocol

    var birthDateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -100, to: .now) ?? .now
        let max = Calendar.current.date(byAdding: .year, value: -13, to: .now) ?? .now
        return min...max
    }

    // MARK: - Initializers

    init(repository: UserProfileRepositoryProtocol, healthKitService: HealthKitServiceProtocol) {
        self.repository = repository
        self.healthKitService = healthKitService
    }

    // MARK: - Functions

    func advance() {
        withAnimation(.spring(response: 0.4)) { currentStep += 1 }
    }

    func goBack() {
        withAnimation(.spring(response: 0.4)) { currentStep -= 1 }
    }

    func connectHealthKit() async {
        try? await healthKitService.requestAuthorization()
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }
        do {
            let trimmedName = name.trimmingCharacters(in: .whitespaces)
            if let existing = try await repository.fetch() {
                existing.name = trimmedName
                existing.birthDate = birthDate
                existing.heightCm = heightCm
                existing.biologicalSex = biologicalSex
                existing.activityLevel = activityLevel
                try await repository.save(existing)
            } else {
                try await repository.save(UserProfile(
                    name: trimmedName,
                    birthDate: birthDate,
                    heightCm: heightCm,
                    biologicalSex: biologicalSex,
                    activityLevel: activityLevel
                ))
            }
        } catch {
            Logger.core.error("Failed to save UserProfile: \(error)")
        }
    }
}

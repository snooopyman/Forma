//
//  EditProfileViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 27/4/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class EditProfileViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let repository: UserProfileRepositoryProtocol

    @ObservationIgnored
    private let profile: UserProfile

    // MARK: - States

    var name: String
    var birthDate: Date
    var heightCm: Double
    var biologicalSex: BiologicalSex
    var activityLevel: ActivityLevel
    var weightUnit: WeightUnit
    var isSaving = false
    var saveSucceeded = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var birthDateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -100, to: .now) ?? .now
        let max = Calendar.current.date(byAdding: .year, value: -10, to: .now) ?? .now
        return min...max
    }

    // MARK: - Initializers

    init(profile: UserProfile, repository: UserProfileRepositoryProtocol) {
        self.profile = profile
        self.repository = repository
        self.name = profile.name
        self.birthDate = profile.birthDate
        self.heightCm = profile.heightCm
        self.biologicalSex = profile.biologicalSex
        self.activityLevel = profile.activityLevel
        self.weightUnit = profile.weightUnit
    }

    // MARK: - Functions

    func save() async {
        guard canSave else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            profile.name = name.trimmingCharacters(in: .whitespaces)
            profile.birthDate = birthDate
            profile.heightCm = heightCm
            profile.biologicalSex = biologicalSex
            profile.activityLevel = activityLevel
            profile.weightUnit = weightUnit
            try await repository.save(profile)
            Logger.core.info("Profile updated")
            saveSucceeded = true
        } catch {
            errorMessage = String(localized: "Something went wrong")
            Logger.core.error("Profile save error: \(error, privacy: .private)")
        }
    }
}

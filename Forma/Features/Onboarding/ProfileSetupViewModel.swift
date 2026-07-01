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
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var canAdvanceFromName: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Private Properties
    
    private let interactor: ProfileSetupInteractorProtocol
    
    var birthDateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -100, to: .now) ?? .now
        let max = Calendar.current.date(byAdding: .year, value: -13, to: .now) ?? .now
        return min...max
    }
    
    // MARK: - Initializers
    
    init(interactor: ProfileSetupInteractorProtocol) {
        self.interactor = interactor
    }
    
    // MARK: - Functions
    
    func advance() {
        withAnimation(.spring(response: 0.4)) { currentStep += 1 }
    }
    
    func goBack() {
        withAnimation(.spring(response: 0.4)) { currentStep -= 1 }
    }
    
    func connectHealthKit() async {
        try? await interactor.requestHealthKitAccess()
    }
    
    func save() async {
        isSaving = true
        defer { isSaving = false }
        do {
            let trimmedName = name.trimmingCharacters(in: .whitespaces)
            if let existing = try await interactor.fetchProfile() {
                existing.name = trimmedName
                existing.birthDate = birthDate
                existing.heightCm = heightCm
                existing.biologicalSex = biologicalSex
                existing.activityLevel = activityLevel
                try await interactor.saveProfile(existing)
            } else {
                try await interactor.saveProfile(UserProfile(
                    name: trimmedName,
                    birthDate: birthDate,
                    heightCm: heightCm,
                    biologicalSex: biologicalSex,
                    activityLevel: activityLevel
                ))
            }
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Functions
    
    private func handleError(_ error: Error) {
        Logger.core.error("Error: \(error, privacy: .private)")
        if let settingsError = error as? SettingsError {
            errorMessage = settingsError.errorDescription
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}

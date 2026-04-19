//
//  NewMeasurementViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 5/4/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class NewMeasurementViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let repository: BodyMeasurementRepositoryProtocol

    @ObservationIgnored
    private let profileRepository: UserProfileRepositoryProtocol

    @ObservationIgnored
    private let existingMeasurement: BodyMeasurement?

    // MARK: - States

    var date: Date
    var weightText = ""
    var heightText = ""
    var neckText = ""
    var armText = ""
    var waistText = ""
    var abdomenText = ""
    var pelvisText = ""
    var thighText = ""
    var notes = ""
    var isSaving = false
    var errorMessage: String?

    // MARK: - Properties

    let onSaved: @MainActor () -> Void

    var isEditing: Bool { existingMeasurement != nil }

    // MARK: - Computed Properties

    var canSave: Bool {
        (Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }

    private var resolvedHeightCm: Double {
        Double(heightText.replacingOccurrences(of: ",", with: ".")) ?? 170
    }

    // MARK: - Initializers

    init(
        repository: BodyMeasurementRepositoryProtocol,
        profileRepository: UserProfileRepositoryProtocol,
        editing: BodyMeasurement? = nil,
        onSaved: @escaping @MainActor () -> Void
    ) {
        self.repository = repository
        self.profileRepository = profileRepository
        self.existingMeasurement = editing
        self.onSaved = onSaved

        if let m = editing {
            self.date = m.date
            self.weightText = m.weightKg.formatted(.number.precision(.fractionLength(1)))
            self.heightText = m.heightCm.formatted(.number.precision(.fractionLength(0)))
            self.neckText = m.neckCm.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? ""
            self.armText = m.armCm.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? ""
            self.waistText = m.waistCm.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? ""
            self.abdomenText = m.abdomenCm.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? ""
            self.pelvisText = m.pelvisCm.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? ""
            self.thighText = m.thighCm.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? ""
            self.notes = m.notes
        } else {
            self.date = .now
        }
    }

    // MARK: - Functions

    func loadProfileHeight() async {
        guard heightText.isEmpty else { return }
        let profile = try? await profileRepository.fetch()
        let h = profile?.heightCm ?? 170
        heightText = h.formatted(.number.precision(.fractionLength(0)))
    }

    func save() async {
        guard canSave else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            let weight = Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
            if let existing = existingMeasurement {
                existing.date = date
                existing.weightKg = weight
                existing.heightCm = resolvedHeightCm
                existing.neckCm = parseOptional(neckText)
                existing.armCm = parseOptional(armText)
                existing.waistCm = parseOptional(waistText)
                existing.abdomenCm = parseOptional(abdomenText)
                existing.pelvisCm = parseOptional(pelvisText)
                existing.thighCm = parseOptional(thighText)
                existing.notes = notes
                try await repository.update(existing)
            } else {
                let profile = try? await profileRepository.fetch()
                let measurement = BodyMeasurement(
                    date: date,
                    weightKg: weight,
                    heightCm: resolvedHeightCm,
                    biologicalSex: profile?.biologicalSex ?? .male,
                    neckCm: parseOptional(neckText),
                    armCm: parseOptional(armText),
                    waistCm: parseOptional(waistText),
                    abdomenCm: parseOptional(abdomenText),
                    pelvisCm: parseOptional(pelvisText),
                    thighCm: parseOptional(thighText),
                    notes: notes
                )
                try await repository.save(measurement)
            }
            Logger.progress.info("Saved measurement: \(weight, privacy: .public) kg")
            onSaved()
        } catch {
            Logger.progress.error("Failed to save measurement: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    // MARK: - Private Functions

    private func parseOptional(_ text: String) -> Double? {
        let cleaned = text.replacingOccurrences(of: ",", with: ".")
        guard !cleaned.isEmpty, let value = Double(cleaned), value > 0 else { return nil }
        return value
    }
}

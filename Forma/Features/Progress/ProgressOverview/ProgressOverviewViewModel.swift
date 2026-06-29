//
//  ProgressOverviewViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 5/4/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class ProgressOverviewViewModel: ProgressOverviewViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: ProgressInteractorProtocol

    // MARK: - States

    var measurements: [BodyMeasurement] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var latest: BodyMeasurement? { measurements.first }

    var weightDelta: Double? {
        guard measurements.count >= 2 else { return nil }
        return measurements[0].weightKg - measurements[1].weightKg
    }

    var bodyFatDelta: Double? {
        guard measurements.count >= 2,
              let current = measurements[0].bodyFatPercent,
              let previous = measurements[1].bodyFatPercent else { return nil }
        return current - previous
    }

    // MARK: - Initializers

    init(interactor: ProgressInteractorProtocol) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            measurements = try await interactor.fetchMeasurements()
        } catch {
            handleError(error)
        }
    }

    func delete(_ measurement: BodyMeasurement) async {
        do {
            try await interactor.deleteMeasurement(measurement)
        } catch {
            handleError(error)
        }
        await load()
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        Logger.progress.error("Error: \(error, privacy: .private)")
        if let progressError = error as? ProgressError {
            errorMessage = progressError.errorDescription
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}

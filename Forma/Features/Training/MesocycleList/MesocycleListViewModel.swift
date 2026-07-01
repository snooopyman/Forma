//
//  MesocycleListViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import os

@Observable
@MainActor
final class MesocycleListViewModel: MesocycleListViewModelProtocol {

    // MARK: - Private Properties

    @ObservationIgnored
    private let interactor: MesocycleListInteractorProtocol

    // MARK: - States

    var mesocycles: [Mesocycle] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var activeMesocycle: Mesocycle? {
        mesocycles.first { $0.isActive }
    }

    // MARK: - Initializers

    init(interactor: MesocycleListInteractorProtocol) {
        self.interactor = interactor
    }

    // MARK: - Functions

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            mesocycles = try await interactor.fetchMesocycles()
        } catch {
            handleError(error)
        }
    }

    func delete(_ mesocycle: Mesocycle) async {
        do {
            try await interactor.deleteMesocycle(mesocycle)
            mesocycles.removeAll { $0.id == mesocycle.id }
        } catch {
            handleError(error)
        }
    }

    func setActive(_ mesocycle: Mesocycle) async {
        do {
            try await interactor.setActiveMesocycle(mesocycle)
            await load()
        } catch {
            handleError(error)
        }
    }

    func createMesocycle(name: String, startDate: Date, durationWeeks: Int, useFixedDays: Bool) async throws {
        try await interactor.createMesocycle(
            name: name,
            startDate: startDate,
            durationWeeks: durationWeeks,
            useFixedDays: useFixedDays
        )
        await load()
    }

    // MARK: - Private Functions

    private func handleError(_ error: Error) {
        Logger.training.error("Error: \(error, privacy: .private)")
        if let trainingError = error as? TrainingError {
            errorMessage = trainingError.errorDescription
        } else {
            errorMessage = L10n.Error.generic
        }
    }
}

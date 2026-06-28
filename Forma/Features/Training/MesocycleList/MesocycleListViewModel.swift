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
final class MesocycleListViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let mesocycleRepository: MesocycleRepositoryProtocol
    
    // MARK: - Properties
    
    var mesocycles: [Mesocycle] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var activeMesocycle: Mesocycle? {
        mesocycles.first { $0.isActive }
    }
    
    // MARK: - Initializers
    
    init(mesocycleRepository: MesocycleRepositoryProtocol) {
        self.mesocycleRepository = mesocycleRepository
    }
    
    // MARK: - Functions
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            mesocycles = try await mesocycleRepository.fetchAll()
        } catch {
            handleError(error)
        }
    }
    
    func delete(_ mesocycle: Mesocycle) async {
        do {
            try await mesocycleRepository.delete(mesocycle)
            mesocycles.removeAll { $0.id == mesocycle.id }
        } catch {
            handleError(error)
        }
    }
    
    func setActive(_ mesocycle: Mesocycle) async {
        do {
            try await mesocycleRepository.setActive(mesocycle)
            await load()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Functions
    
    private func handleError(_ error: Error) {
        Logger.training.error("Error: \(error, privacy: .private)")
        if let trainingError = error as? TrainingError {
            errorMessage = trainingError.errorDescription
        } else {
            errorMessage = String(localized: "Something went wrong")
        }
    }
}

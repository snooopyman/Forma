//
//  WeeklyVolumeViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import Foundation
import OSLog

@Observable
@MainActor
final class WeeklyVolumeViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: WeeklyVolumeInteractorProtocol
    
    // MARK: - States
    
    var snapshot: WeeklyVolumeSnapshot?
    var targets: [MuscleVolumeTarget] = []
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var sortedTargets: [MuscleVolumeTarget] {
        let order = MuscleGroup.allCases
        return targets.sorted {
            (order.firstIndex(of: $0.muscleGroup) ?? 0) < (order.firstIndex(of: $1.muscleGroup) ?? 0)
        }
    }
    
    // MARK: - Initializers
    
    init(interactor: WeeklyVolumeInteractorProtocol) {
        self.interactor = interactor
    }
    
    // MARK: - Functions
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            snapshot = try await interactor.loadSnapshot()
        } catch {
            handleError(error)
        }
    }
    
    func loadTargets() async {
        do {
            targets = try await interactor.fetchTargets()
        } catch {
            handleError(error)
        }
    }
    
    func setUpDefaultTargets() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await interactor.seedDefaultTargets()
            await load()
            await loadTargets()
        } catch {
            handleError(error)
        }
    }
    
    func restoreDefaultTargets() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await interactor.restoreDefaultTargets()
            await load()
            await loadTargets()
        } catch {
            handleError(error)
        }
    }
    
    func save(_ target: MuscleVolumeTarget) async {
        do {
            try await interactor.saveTarget(target)
        } catch {
            handleError(error)
        }
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

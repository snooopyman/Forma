//
//  WorkoutDayDetailViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import os

@Observable
@MainActor
final class WorkoutDayDetailViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let mesocycleRepository: MesocycleRepositoryProtocol
    
    @ObservationIgnored
    private let sessionService: WorkoutSessionServiceProtocol
    
    @ObservationIgnored
    private let sessionRepository: WorkoutSessionRepositoryProtocol
    
    // MARK: - Properties
    
    let workoutDay: WorkoutDay
    var inProgressSession: WorkoutSession?
    var isLoading = false
    var isStarting = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var sortedExercises: [PlannedExercise] {
        workoutDay.plannedExercises.sorted { $0.order < $1.order }
    }
    
    var canStartSession: Bool {
        guard let mesocycle = workoutDay.mesocycle else { return false }
        return mesocycle.isActive
        && !mesocycle.isPaused
        && !workoutDay.isRestDay
        && !workoutDay.plannedExercises.isEmpty
    }
    
    // MARK: - Initializers
    
    init(
        workoutDay: WorkoutDay,
        mesocycleRepository: MesocycleRepositoryProtocol,
        sessionService: WorkoutSessionServiceProtocol,
        sessionRepository: WorkoutSessionRepositoryProtocol
    ) {
        self.workoutDay = workoutDay
        self.mesocycleRepository = mesocycleRepository
        self.sessionService = sessionService
        self.sessionRepository = sessionRepository
    }
    
    // MARK: - Functions
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            inProgressSession = try await sessionRepository.fetchInProgress()
        } catch {
            handleError(error)
        }
    }
    
    func deleteExercise(_ planned: PlannedExercise) async {
        do {
            try await mesocycleRepository.deletePlannedExercise(planned)
        } catch {
            handleError(error)
        }
    }
    
    func startSession() async throws -> WorkoutSession {
        guard let mesocycle = workoutDay.mesocycle else {
            throw WorkoutDayError.noMesocycle
        }
        isStarting = true
        defer { isStarting = false }
        return try await sessionService.startSession(for: workoutDay, in: mesocycle)
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

enum WorkoutDayError: Error {
    case noMesocycle
}

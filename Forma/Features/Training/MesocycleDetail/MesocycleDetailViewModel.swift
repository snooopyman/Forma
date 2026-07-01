//
//  MesocycleDetailViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import os

@Observable
@MainActor
final class MesocycleDetailViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: MesocycleDetailInteractorProtocol
    
    // MARK: - Properties
    
    let mesocycle: Mesocycle
    var sessions: [WorkoutSession] = []
    var inProgressSession: WorkoutSession?
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var sortedWorkoutDays: [WorkoutDay] {
        mesocycle.workoutDays.sorted { $0.order < $1.order }
    }
    
    // MARK: - Initializers
    
    init(
        mesocycle: Mesocycle,
        interactor: MesocycleDetailInteractorProtocol
    ) {
        self.mesocycle = mesocycle
        self.interactor = interactor
    }
    
    // MARK: - Functions
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            sessions = try await interactor.fetchSessions(for: mesocycle)
            inProgressSession = try await interactor.fetchInProgressSession()
        } catch {
            handleError(error)
        }
    }
    
    func activate() async {
        do {
            try await interactor.activate(mesocycle)
        } catch {
            handleError(error)
        }
    }
    
    func pause() async {
        do {
            try await interactor.pause(mesocycle)
        } catch {
            handleError(error)
        }
    }
    
    func resume() async {
        do {
            try await interactor.resume(mesocycle)
        } catch {
            handleError(error)
        }
    }
    
    func completedSessionCount(for day: WorkoutDay) -> Int {
        sessions.filter { $0.workoutDay?.id == day.id && $0.isCompleted }.count
    }
    
    func addWorkoutDay(name: String, isRestDay: Bool, weekday: Weekday?) async {
        let order = mesocycle.workoutDays.count
        let day = WorkoutDay(
            name: name,
            order: order,
            weekday: isRestDay ? nil : weekday,
            isRestDay: isRestDay
        )
        do {
            try await interactor.addWorkoutDay(day, to: mesocycle)
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
            errorMessage = L10n.Error.generic
        }
    }
}

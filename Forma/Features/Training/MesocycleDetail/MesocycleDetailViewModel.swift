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
    private let mesocycleRepository: MesocycleRepositoryProtocol

    @ObservationIgnored
    private let sessionRepository: WorkoutSessionRepositoryProtocol

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
        mesocycleRepository: MesocycleRepositoryProtocol,
        sessionRepository: WorkoutSessionRepositoryProtocol
    ) {
        self.mesocycle = mesocycle
        self.mesocycleRepository = mesocycleRepository
        self.sessionRepository = sessionRepository
    }

    // MARK: - Functions

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            sessions = try await sessionRepository.fetchAll(for: mesocycle)
            inProgressSession = try await sessionRepository.fetchInProgress()
        } catch {
            Logger.training.error("MesocycleDetail load error: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func activate() async {
        do {
            try await mesocycleRepository.setActive(mesocycle)
        } catch {
            Logger.training.error("Failed to activate mesocycle: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func pause() async {
        do {
            try await mesocycleRepository.pause(mesocycle)
        } catch {
            Logger.training.error("Failed to pause mesocycle: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func resume() async {
        do {
            try await mesocycleRepository.resume(mesocycle)
        } catch {
            Logger.training.error("Failed to resume mesocycle: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
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
            try await mesocycleRepository.addWorkoutDay(day, to: mesocycle)
        } catch {
            Logger.training.error("Failed to add workout day: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }
}

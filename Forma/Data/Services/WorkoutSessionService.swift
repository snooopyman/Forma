//
//  WorkoutSessionService.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import os

struct SetInput: Sendable {
    let exerciseName: String
    let weightKg: Double
    let reps: Int
    let rirActual: Int?
    let notes: String

    init(exerciseName: String, weightKg: Double, reps: Int, rirActual: Int? = nil, notes: String = "") {
        self.exerciseName = exerciseName
        self.weightKg = weightKg
        self.reps = reps
        self.rirActual = rirActual
        self.notes = notes
    }
}

protocol WorkoutSessionServiceProtocol: Sendable {
    func startSession(for workoutDay: WorkoutDay, in mesocycle: Mesocycle) async throws -> WorkoutSession
    func logSet(_ input: SetInput, order: Int, to session: WorkoutSession, plannedExercise: PlannedExercise?) async throws -> LoggedSet
    func deleteSet(_ set: LoggedSet, from session: WorkoutSession) async throws
    func completeSession(_ session: WorkoutSession) async throws
    func discardSession(_ session: WorkoutSession) async throws
    func fetchLastSets(for workoutDay: WorkoutDay, exerciseName: String) async throws -> [LoggedSet]
}

final class WorkoutSessionService: WorkoutSessionServiceProtocol {

    // MARK: - Private Properties

    private let sessionRepository: WorkoutSessionRepositoryProtocol

    // MARK: - Initializers

    init(sessionRepository: WorkoutSessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    // MARK: - Functions

    func startSession(for workoutDay: WorkoutDay, in mesocycle: Mesocycle) async throws -> WorkoutSession {
        let session = WorkoutSession(
            sessionType: workoutDay.isRestDay ? .mobility : .planned
        )
        session.workoutDay = workoutDay
        session.mesocycle = mesocycle
        try await sessionRepository.save(session)
        Logger.training.info("Session started for day: \(workoutDay.name, privacy: .public)")
        return session
    }

    func logSet(_ input: SetInput, order: Int, to session: WorkoutSession, plannedExercise: PlannedExercise?) async throws -> LoggedSet {
        let set = LoggedSet(
            order: order,
            exerciseName: input.exerciseName,
            weightKg: input.weightKg,
            reps: input.reps,
            rirActual: input.rirActual,
            notes: input.notes
        )
        set.plannedExercise = plannedExercise
        set.session = session
        try await sessionRepository.addSet(set, to: session)
        Logger.training.info("Set logged: \(input.exerciseName, privacy: .public) \(input.weightKg, privacy: .public)kg × \(input.reps, privacy: .public)")
        return set
    }

    func deleteSet(_ set: LoggedSet, from session: WorkoutSession) async throws {
        try await sessionRepository.deleteSet(set)
    }

    func completeSession(_ session: WorkoutSession) async throws {
        session.completedAt = .now
        try await sessionRepository.save(session)
        Logger.training.info("Session completed, duration: \(session.duration ?? 0, privacy: .public)s")
    }

    func discardSession(_ session: WorkoutSession) async throws {
        try await sessionRepository.delete(session)
        Logger.training.info("Session discarded")
    }

    func fetchLastSets(for workoutDay: WorkoutDay, exerciseName: String) async throws -> [LoggedSet] {
        let sessions = try await sessionRepository.fetchCompleted(for: workoutDay)
        guard let lastSession = sessions.first else { return [] }
        return lastSession.loggedSets
            .filter { $0.exerciseName == exerciseName }
            .sorted { $0.order < $1.order }
    }
}

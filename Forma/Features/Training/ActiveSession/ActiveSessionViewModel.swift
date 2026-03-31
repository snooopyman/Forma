//
//  ActiveSessionViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import os

@Observable
@MainActor
final class ActiveSessionViewModel {

    // MARK: - Private Properties

    @ObservationIgnored
    private let sessionService: WorkoutSessionServiceProtocol

    @ObservationIgnored
    private let restTimerActivityService: RestTimerActivityServiceProtocol

    @ObservationIgnored
    private var restTimerTask: Task<Void, Never>?

    // MARK: - Properties

    let session: WorkoutSession
    let workoutDay: WorkoutDay

    var currentExerciseIndex = 0
    var isCompleting = false
    var showFinishConfirmation = false
    var showDiscardConfirmation = false
    var isCompleted = false
    var errorMessage: String?

    // Keyed by PlannedExercise.id
    var weightInputs: [UUID: String] = [:]
    var repsInputs: [UUID: String] = [:]
    var rirInputs: [UUID: String] = [:]

    var restSecondsRemaining = 0
    var isResting = false
    var restJustEnded = false

    // MARK: - Computed Properties

    var sortedExercises: [PlannedExercise] {
        workoutDay.plannedExercises.sorted { $0.order < $1.order }
    }

    var currentExercise: PlannedExercise? {
        guard !sortedExercises.isEmpty,
              currentExerciseIndex < sortedExercises.count else { return nil }
        return sortedExercises[currentExerciseIndex]
    }

    var elapsedTime: TimeInterval {
        Date.now.timeIntervalSince(session.startedAt)
    }

    var canNavigatePrevious: Bool { currentExerciseIndex > 0 }
    var canNavigateNext: Bool { currentExerciseIndex < sortedExercises.count - 1 }

    // MARK: - Initializers

    init(
        session: WorkoutSession,
        workoutDay: WorkoutDay,
        sessionService: WorkoutSessionServiceProtocol,
        restTimerActivityService: RestTimerActivityServiceProtocol
    ) {
        self.session = session
        self.workoutDay = workoutDay
        self.sessionService = sessionService
        self.restTimerActivityService = restTimerActivityService
    }

    // MARK: - Functions

    func loggedSets(for exercise: PlannedExercise) -> [LoggedSet] {
        session.loggedSets
            .filter { $0.plannedExercise?.id == exercise.id }
            .sorted { $0.order < $1.order }
    }

    func nextSetNumber(for exercise: PlannedExercise) -> Int {
        loggedSets(for: exercise).count + 1
    }

    func setRowState(setNumber: Int, for exercise: PlannedExercise) -> SetRowState {
        let logged = loggedSets(for: exercise)
        let completedCount = logged.count
        if setNumber <= completedCount { return .completed }
        if setNumber == completedCount + 1 { return .active }
        return .pending
    }

    func navigatePrevious() {
        guard canNavigatePrevious else { return }
        currentExerciseIndex -= 1
    }

    func navigateNext() {
        guard canNavigateNext else { return }
        currentExerciseIndex += 1
    }

    func logSet(for exercise: PlannedExercise) async {
        let weightText = weightInputs[exercise.id] ?? ""
        let repsText = repsInputs[exercise.id] ?? ""

        guard let weight = Double(weightText), let reps = Int(repsText) else {
            errorMessage = String(localized: "Enter valid weight and reps")
            return
        }

        let rirText = rirInputs[exercise.id] ?? ""
        let rir = Int(rirText)
        let order = nextSetNumber(for: exercise)
        let name = exercise.exercise?.name ?? ""

        let input = SetInput(exerciseName: name, weightKg: weight, reps: reps, rirActual: rir)
        do {
            _ = try await sessionService.logSet(input, order: order, to: session, plannedExercise: exercise)
            startRestTimer(seconds: exercise.restSeconds)
        } catch {
            Logger.training.error("Failed to log set: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func deleteSet(_ set: LoggedSet) async {
        do {
            try await sessionService.deleteSet(set, from: session)
        } catch {
            Logger.training.error("Failed to delete set: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func completeSession() async {
        isCompleting = true
        defer { isCompleting = false }
        do {
            try await sessionService.completeSession(session)
            restTimerTask?.cancel()
            await restTimerActivityService.endActivity()
            isCompleted = true
        } catch {
            Logger.training.error("Failed to complete session: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func discardSession() async {
        do {
            restTimerTask?.cancel()
            await restTimerActivityService.endActivity()
            try await sessionService.discardSession(session)
            isCompleted = true
        } catch {
            Logger.training.error("Failed to discard session: \(error, privacy: .private)")
            errorMessage = String(localized: "Something went wrong")
        }
    }

    func loadLastWeight(for exercise: PlannedExercise) async {
        guard weightInputs[exercise.id] == nil,
              let name = exercise.exercise?.name else { return }
        do {
            let lastSets = try await sessionService.fetchLastSets(
                for: workoutDay, exerciseName: name
            )
            if let lastSet = lastSets.first {
                weightInputs[exercise.id] = lastSet.weightKg.asWeight
            }
        } catch {
            Logger.training.error("Failed to load last weight: \(error, privacy: .private)")
        }
    }

    func skipRest() {
        restTimerTask?.cancel()
        restSecondsRemaining = 0
        isResting = false
        Task { await restTimerActivityService.endActivity() }
    }

    // MARK: - Private Functions

    private func startRestTimer(seconds: Int) {
        restTimerTask?.cancel()
        guard seconds > 0 else { return }
        restSecondsRemaining = seconds
        isResting = true

        let exerciseName = currentExercise?.exercise?.name ?? ""

        restTimerTask = Task { [weak self] in
            guard let self else { return }
            await restTimerActivityService.startActivity(exerciseName: exerciseName, seconds: seconds)

            for remaining in stride(from: seconds - 1, through: 0, by: -1) {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                restSecondsRemaining = remaining
            }
            if !Task.isCancelled {
                isResting = false
                restJustEnded = true
                await restTimerActivityService.endActivity()
            }
        }
    }
}

//
//  MockActiveSessionViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

@Observable
@MainActor
final class MockActiveSessionViewModel: ActiveSessionViewModelProtocol {

    // MARK: - Properties

    let session: WorkoutSession
    let workoutDay: WorkoutDay

    // MARK: - States

    var currentExerciseIndex: Int = 0
    var isCompleting: Bool = false
    var showFinishConfirmation: Bool = false
    var showDiscardConfirmation: Bool = false
    var isCompleted: Bool = false
    var errorMessage: String?
    var weightInputs: [UUID: String] = [:]
    var repsInputs: [UUID: String] = [:]
    var rirInputs: [UUID: String] = [:]
    var restSecondsRemaining: Int = 0
    var isResting: Bool = false
    var restJustEnded: Bool = false
    var wasExportedToHealth: Bool = false

    // MARK: - Computed Properties

    var sortedExercises: [PlannedExercise] { workoutDay.plannedExercises.sorted { $0.order < $1.order } }
    var currentExercise: PlannedExercise? { sortedExercises.isEmpty ? nil : sortedExercises[safe: currentExerciseIndex] }
    var elapsedTime: TimeInterval { Date.now.timeIntervalSince(session.startedAt) }
    var canNavigatePrevious: Bool { currentExerciseIndex > 0 }
    var canNavigateNext: Bool { currentExerciseIndex < sortedExercises.count - 1 }

    // MARK: - Initializers

    init(session: WorkoutSession, workoutDay: WorkoutDay) {
        self.session = session
        self.workoutDay = workoutDay
    }

    // MARK: - Functions

    func loggedSets(for exercise: PlannedExercise) -> [LoggedSet] { [] }
    func nextSetNumber(for exercise: PlannedExercise) -> Int { 1 }
    func setRowState(setNumber: Int, for exercise: PlannedExercise) -> SetRowState { .pending }
    func navigatePrevious() { if canNavigatePrevious { currentExerciseIndex -= 1 } }
    func navigateNext() { if canNavigateNext { currentExerciseIndex += 1 } }
    func logSet(for exercise: PlannedExercise) async { }
    func deleteSet(_ set: LoggedSet) async { }
    func completeSession() async { isCompleted = true }
    func discardSession() async { isCompleted = true }
    func loadLastWeight(for exercise: PlannedExercise) async { }
    func skipRest() { isResting = false }
}

// MARK: - Collection+Safe

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

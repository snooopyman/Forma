//
//  ActiveSessionViewModelProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

@MainActor
protocol ActiveSessionViewModelProtocol {
    var session: WorkoutSession { get }
    var workoutDay: WorkoutDay { get }
    var currentExerciseIndex: Int { get set }
    var isCompleting: Bool { get }
    var showFinishConfirmation: Bool { get set }
    var showDiscardConfirmation: Bool { get set }
    var isCompleted: Bool { get }
    var errorMessage: String? { get set }
    var weightInputs: [UUID: String] { get set }
    var repsInputs: [UUID: String] { get set }
    var rirInputs: [UUID: String] { get set }
    var restSecondsRemaining: Int { get }
    var isResting: Bool { get }
    var restJustEnded: Bool { get set }
    var wasExportedToHealth: Bool { get }
    var sortedExercises: [PlannedExercise] { get }
    var currentExercise: PlannedExercise? { get }
    var elapsedTime: TimeInterval { get }
    var canNavigatePrevious: Bool { get }
    var canNavigateNext: Bool { get }
    
    func loggedSets(for exercise: PlannedExercise) -> [LoggedSet]
    func nextSetNumber(for exercise: PlannedExercise) -> Int
    func setRowState(setNumber: Int, for exercise: PlannedExercise) -> SetRowState
    func navigatePrevious()
    func navigateNext()
    func logSet(for exercise: PlannedExercise) async
    func deleteSet(_ set: LoggedSet) async
    func completeSession() async
    func discardSession() async
    func loadLastWeight(for exercise: PlannedExercise) async
    func skipRest()
}

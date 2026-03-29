//
//  LoggedSet.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class LoggedSet {

    var id: UUID
    var order: Int
    // Denormalized to preserve history if the exercise is later renamed or deleted
    var exerciseName: String
    var weightKg: Double
    var reps: Int
    var rirActual: Int?
    var completedAt: Date
    var notes: String

    var plannedExercise: PlannedExercise?
    var session: WorkoutSession?

    init(
        id: UUID = UUID(),
        order: Int,
        exerciseName: String,
        weightKg: Double,
        reps: Int,
        rirActual: Int? = nil,
        completedAt: Date = .now,
        notes: String = ""
    ) {
        self.id = id
        self.order = order
        self.exerciseName = exerciseName
        self.weightKg = weightKg
        self.reps = reps
        self.rirActual = rirActual
        self.completedAt = completedAt
        self.notes = notes
    }
}

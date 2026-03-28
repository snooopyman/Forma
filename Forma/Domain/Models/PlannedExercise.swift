import Foundation
import SwiftData

@Model
final class PlannedExercise {

    var id: UUID
    var order: Int
    var sets: Int
    var repsMin: Int
    var repsMax: Int
    var rirTarget: Int
    var restSeconds: Int
    // "eccentric-pause-concentric", e.g. "2-0-1"
    var cadence: String
    var notes: String

    var exercise: Exercise?
    var workoutDay: WorkoutDay?

    init(
        id: UUID = UUID(),
        order: Int,
        sets: Int = 3,
        repsMin: Int = 8,
        repsMax: Int = 12,
        rirTarget: Int = 2,
        restSeconds: Int = 120,
        cadence: String = "2-0-1",
        notes: String = ""
    ) {
        self.id = id
        self.order = order
        self.sets = sets
        self.repsMin = repsMin
        self.repsMax = repsMax
        self.rirTarget = rirTarget
        self.restSeconds = restSeconds
        self.cadence = cadence
        self.notes = notes
    }
}

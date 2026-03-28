import Foundation
import SwiftData

@Model
final class MuscleVolumeTarget {

    var id: UUID
    var muscleGroup: MuscleGroup
    var mevSets: Int
    var mavSets: Int
    var mrvSets: Int

    init(
        id: UUID = UUID(),
        muscleGroup: MuscleGroup,
        mevSets: Int,
        mavSets: Int,
        mrvSets: Int
    ) {
        self.id = id
        self.muscleGroup = muscleGroup
        self.mevSets = mevSets
        self.mavSets = mavSets
        self.mrvSets = mrvSets
    }
}

//
//  MuscleVolumeTarget.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class MuscleVolumeTarget {
    
    var id: UUID = UUID()
    var muscleGroup: MuscleGroup = MuscleGroup.fullBody
    var mevSets: Int = 0
    var mavSets: Int = 0
    var mrvSets: Int = 0
    
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

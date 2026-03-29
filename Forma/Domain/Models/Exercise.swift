//
//  Exercise.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class Exercise {

    var id: UUID
    var name: String
    var primaryMuscle: MuscleGroup
    var secondaryMuscles: [MuscleGroup]
    var equipment: String
    var movementPattern: String
    var instructions: String
    var isCustom: Bool

    init(
        id: UUID = UUID(),
        name: String,
        primaryMuscle: MuscleGroup,
        secondaryMuscles: [MuscleGroup] = [],
        equipment: String = "",
        movementPattern: String = "",
        instructions: String = "",
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.primaryMuscle = primaryMuscle
        self.secondaryMuscles = secondaryMuscles
        self.equipment = equipment
        self.movementPattern = movementPattern
        self.instructions = instructions
        self.isCustom = isCustom
    }
}

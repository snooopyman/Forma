//
//  MuscleGroupBadge.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct MuscleGroupBadge: View {
    let muscleGroup: MuscleGroup
    
    var body: some View {
        Text(muscleGroup.localizedName)
            .font(.caption.weight(.medium))
            .foregroundStyle(muscleGroup.color)
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, DS.Spacing.xs)
            .background(muscleGroup.color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.chip))
    }
}

#Preview {
    HStack {
        MuscleGroupBadge(muscleGroup: .chest)
        MuscleGroupBadge(muscleGroup: .back)
        MuscleGroupBadge(muscleGroup: .legs)
        MuscleGroupBadge(muscleGroup: .shoulders)
    }
    .padding()
}

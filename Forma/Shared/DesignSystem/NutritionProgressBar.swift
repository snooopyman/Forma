//
//  NutritionProgressBar.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct NutritionProgressBar: View {
    let current: Double
    let goal: Double

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return (current / goal).clamped(to: 0...1)
    }

    private var barColor: Color {
        let ratio = goal > 0 ? current / goal : 0
        if ratio >= 1.0 { return .warning }
        if ratio >= 0.85 { return .success }
        return .accent
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: DS.Radius.inner)
                    .fill(.backgroundSecondary)

                RoundedRectangle(cornerRadius: DS.Radius.inner)
                    .fill(barColor)
                    .frame(width: geo.size.width * progress)
                    .animation(.spring(duration: 0.4), value: progress)
            }
        }
    }
}

#Preview {
    VStack(spacing: DS.Spacing.md) {
        NutritionProgressBar(current: 10, goal: 160).frame(height: 8)
        NutritionProgressBar(current: 100, goal: 160).frame(height: 8)
        NutritionProgressBar(current: 150, goal: 160).frame(height: 8)
        NutritionProgressBar(current: 160, goal: 160).frame(height: 8)
    }
    .padding()
}

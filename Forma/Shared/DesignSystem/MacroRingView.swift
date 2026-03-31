//
//  MacroRingView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI
import Charts

struct MacroRingView: View {
    let proteinCurrent: Double
    let proteinGoal: Double
    let carbsCurrent: Double
    let carbsGoal: Double
    let fatCurrent: Double
    let fatGoal: Double

    var body: some View {
        ZStack {
            MacroRing(current: fatCurrent, goal: fatGoal, color: .macroFat, diameter: DS.Sizing.macroRingOuter)
            MacroRing(current: carbsCurrent, goal: carbsGoal, color: .macroCarbs, diameter: DS.Sizing.macroRingMiddle)
            MacroRing(current: proteinCurrent, goal: proteinGoal, color: .macroProtein, diameter: DS.Sizing.macroRingInner)
        }
        .frame(width: DS.Sizing.macroRingOuter, height: DS.Sizing.macroRingOuter)
    }
}

private struct MacroRing: View {
    let current: Double
    let goal: Double
    let color: Color
    let diameter: CGFloat

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return (current / goal).clamped(to: 0...1)
    }

    private let lineWidth: CGFloat = 10

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.6), value: progress)
        }
        .frame(width: diameter, height: diameter)
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    MacroRingView(
        proteinCurrent: 120, proteinGoal: 160,
        carbsCurrent: 180, carbsGoal: 250,
        fatCurrent: 55, fatGoal: 70
    )
    .padding()
}

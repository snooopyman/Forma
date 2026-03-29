//
//  ExerciseSetRow.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

enum SetRowState {
    case pending
    case active
    case completed
}

struct ExerciseSetRow: View {
    let setNumber: Int
    let targetReps: Int
    let targetWeight: Double
    let rir: Int
    let state: SetRowState
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            setIndicator

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "\(targetWeight) kg × \(targetReps)")
                    .font(.body.weight(.semibold).monospaced())
                    .foregroundStyle(labelColor)

                Text("RIR \(rir)")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            if state != .completed {
                Button(action: onComplete) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(state == .active ? Color.accent : Color.textTertiary)
                }
                .frame(minWidth: DS.Sizing.minTapTarget, minHeight: DS.Sizing.minTapTarget)
                .accessibilityLabel("Complete set \(setNumber)")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.success)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.setRow))
        .animation(.spring(duration: 0.3), value: state)
    }

    @ViewBuilder
    private var setIndicator: some View {
        Text(verbatim: "\(setNumber)")
            .font(.caption.weight(.bold).monospaced())
            .foregroundStyle(indicatorForeground)
            .frame(width: 28, height: 28)
            .background(indicatorBackground)
            .clipShape(Circle())
    }

    private var rowBackground: Color {
        switch state {
        case .pending:   return Color.backgroundCard
        case .active:    return Color.accent.opacity(0.08)
        case .completed: return Color.success.opacity(0.08)
        }
    }

    private var labelColor: Color {
        switch state {
        case .pending:   return Color.textPrimary
        case .active:    return Color.accent
        case .completed: return Color.textSecondary
        }
    }

    private var indicatorBackground: Color {
        switch state {
        case .pending:   return Color.backgroundSecondary
        case .active:    return Color.accent
        case .completed: return Color.success
        }
    }

    private var indicatorForeground: Color {
        switch state {
        case .pending:   return Color.textSecondary
        case .active, .completed: return Color.textOnAccent
        }
    }
}

#Preview {
    VStack(spacing: DS.Spacing.sm) {
        ExerciseSetRow(setNumber: 1, targetReps: 8, targetWeight: 80, rir: 2, state: .completed, onComplete: {})
        ExerciseSetRow(setNumber: 2, targetReps: 8, targetWeight: 80, rir: 2, state: .active, onComplete: {})
        ExerciseSetRow(setNumber: 3, targetReps: 8, targetWeight: 80, rir: 2, state: .pending, onComplete: {})
    }
    .padding()
    .background(Color.backgroundPrimary)
}

//
//  RestTimerLiveActivity.swift
//  FormaLiveActivity
//
//  Created by Armando Cáceres on 31/3/26.
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Widget

struct RestTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            RestTimerLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.blue)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date.now...context.state.endsAt, countsDown: true)
                        .font(.title2.weight(.bold).monospacedDigit())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.exerciseName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    let startDate = context.state.endsAt
                        .addingTimeInterval(-Double(context.attributes.totalSeconds))
                    ProgressView(timerInterval: startDate...context.state.endsAt, countsDown: false) {
                        EmptyView()
                    } currentValueLabel: {
                        EmptyView()
                    }
                    .progressViewStyle(.linear)
                    .tint(.blue)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(.blue)
            } compactTrailing: {
                Text(timerInterval: Date.now...context.state.endsAt, countsDown: true)
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.primary)
                    .frame(minWidth: 36)
            } minimal: {
                Text(timerInterval: Date.now...context.state.endsAt, countsDown: true)
                    .font(.caption2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.primary)
            }
        }
    }
}

// MARK: - Lock Screen View

private struct RestTimerLockScreenView: View {
    let context: ActivityViewContext<RestTimerAttributes>

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "timer")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.exerciseName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(timerInterval: Date.now...context.state.endsAt, countsDown: true)
                    .font(.title.weight(.bold).monospacedDigit())
                    .foregroundStyle(.primary)
            }

            Spacer()

            let startDate = context.state.endsAt
                .addingTimeInterval(-Double(context.attributes.totalSeconds))
            ProgressView(timerInterval: startDate...context.state.endsAt, countsDown: false) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }
            .progressViewStyle(.circular)
            .tint(.blue)
            .frame(width: 44, height: 44)
        }
        .padding(16)
    }
}

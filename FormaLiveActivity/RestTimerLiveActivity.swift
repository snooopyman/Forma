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
                    ExpandedLeadingView()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                CompactLeadingView()
            } compactTrailing: {
                CompactTrailingView(context: context)
            } minimal: {
                MinimalView(context: context)
            }
        }
        .supplementalActivityFamilies([.small])
    }
}

// MARK: - Dynamic Island — Expanded Regions

private struct ExpandedLeadingView: View {
    var body: some View {
        Image(systemName: "timer")
            .font(.title2.weight(.semibold))
            .foregroundStyle(.blue)
            .padding(.leading, 4)
    }
}

private struct ExpandedTrailingView: View {
    let context: ActivityViewContext<RestTimerAttributes>
    
    var body: some View {
        Text(timerInterval: Date.now...context.state.endsAt, countsDown: true)
            .font(.title2.weight(.bold).monospacedDigit())
            .foregroundStyle(.primary)
            .multilineTextAlignment(.trailing)
            .padding(.trailing, 4)
    }
}

private struct ExpandedCenterView: View {
    let context: ActivityViewContext<RestTimerAttributes>
    
    var body: some View {
        Text(context.attributes.exerciseName)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

private struct ExpandedBottomView: View {
    let context: ActivityViewContext<RestTimerAttributes>
    
    var body: some View {
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
}

// MARK: - Dynamic Island — Compact & Minimal

private struct CompactLeadingView: View {
    var body: some View {
        Image(systemName: "timer")
            .foregroundStyle(.blue)
    }
}

private struct CompactTrailingView: View {
    
    // MARK: Properties
    
    let context: ActivityViewContext<RestTimerAttributes>
    
    // MARK: Body
    
    var body: some View {
        Text(timerInterval: Date.now...context.state.endsAt, countsDown: true)
            .font(.caption.weight(.semibold).monospacedDigit())
            .foregroundStyle(.primary)
            .frame(minWidth: 36)
    }
}

private struct MinimalView: View {
    
    // MARK: Properties
    
    let context: ActivityViewContext<RestTimerAttributes>
    
    // MARK: Body
    
    var body: some View {
        Text(timerInterval: Date.now...context.state.endsAt, countsDown: true)
            .font(.caption2.weight(.semibold).monospacedDigit())
            .foregroundStyle(.primary)
    }
}

// MARK: - Lock Screen / StandBy / Watch & CarPlay (.small)

private struct RestTimerLockScreenView: View {
    
    // MARK: Environment
    
    @Environment(\.showsWidgetContainerBackground) private var showsWidgetContainerBackground
    @Environment(\.activityFamily) private var activityFamily
    
    // MARK: Properties
    
    let context: ActivityViewContext<RestTimerAttributes>
    
    // MARK: Body
    
    var body: some View {
        contentView
            .background {
                if showsWidgetContainerBackground {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.12), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .activityBackgroundTint(Color.black.opacity(0.75))
    }
    
    // MARK: Private Views
    
    @ViewBuilder
    private var contentView: some View {
        if activityFamily == .small {
            RestTimerSmallView(
                exerciseName: context.attributes.exerciseName,
                endsAt: context.state.endsAt
            )
        } else {
            RestTimerDetailView(context: context)
        }
    }
}

/// Full layout used on the Lock Screen and StandBy (scaled 2x).
private struct RestTimerDetailView: View {
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

/// Compact layout for the `.small` supplemental family — Apple Watch Smart Stack and CarPlay.
private struct RestTimerSmallView: View {
    let exerciseName: String
    let endsAt: Date
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "timer")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.blue)
            
            Text(timerInterval: Date.now...endsAt, countsDown: true)
                .font(.headline.weight(.bold).monospacedDigit())
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            Text(exerciseName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(8)
    }
}

// MARK: - Preview Data

extension RestTimerAttributes {
    fileprivate static var preview: RestTimerAttributes {
        RestTimerAttributes(exerciseName: "Barbell Bench Press", totalSeconds: 90)
    }
}

extension RestTimerAttributes.ContentState {
    fileprivate static var running: RestTimerAttributes.ContentState {
        RestTimerAttributes.ContentState(endsAt: .now.addingTimeInterval(63))
    }
    
    fileprivate static var almostDone: RestTimerAttributes.ContentState {
        RestTimerAttributes.ContentState(endsAt: .now.addingTimeInterval(4))
    }
}

// MARK: - Previews

#Preview("Lock Screen / StandBy", as: .content, using: RestTimerAttributes.preview) {
    RestTimerLiveActivity()
} contentStates: {
    RestTimerAttributes.ContentState.running
    RestTimerAttributes.ContentState.almostDone
}

#Preview("Dynamic Island — Expanded", as: .dynamicIsland(.expanded), using: RestTimerAttributes.preview) {
    RestTimerLiveActivity()
} contentStates: {
    RestTimerAttributes.ContentState.running
}

#Preview("Dynamic Island — Compact", as: .dynamicIsland(.compact), using: RestTimerAttributes.preview) {
    RestTimerLiveActivity()
} contentStates: {
    RestTimerAttributes.ContentState.running
}

#Preview("Dynamic Island — Minimal", as: .dynamicIsland(.minimal), using: RestTimerAttributes.preview) {
    RestTimerLiveActivity()
} contentStates: {
    RestTimerAttributes.ContentState.running
}

#Preview("Watch / CarPlay (.small)") {
    RestTimerSmallView(exerciseName: "Barbell Bench Press", endsAt: .now.addingTimeInterval(63))
        .padding(8)
        .background(Color.black.opacity(0.75))
}

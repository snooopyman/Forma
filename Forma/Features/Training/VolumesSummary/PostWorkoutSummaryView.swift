//
//  PostWorkoutSummaryView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI
import SwiftData

struct PostWorkoutSummaryView: View {

    // MARK: - Properties

    let session: WorkoutSession
    let volumeCalculatorService: VolumeCalculatorServiceProtocol
    let onDone: () -> Void

    // MARK: - Computed Properties

    private var summary: SessionVolumeSummary {
        volumeCalculatorService.calculate(for: session)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                headerView
                statsGrid
                if !summary.volumeByMuscle.isEmpty {
                    muscleBreakdownSection
                }
            }
            .padding(DS.Spacing.lg)
        }
        .safeAreaInset(edge: .bottom) {
            doneButton
                .padding(DS.Spacing.lg)
        }
        .navigationTitle(String(localized: "Workout complete"))
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Private Views

    private var headerView: some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.success)
            Text(String(localized: "Great workout!"))
                .font(.title.weight(.bold))
                .foregroundStyle(.textPrimary)
            Text(session.date.formatted(date: .long, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
        }
        .padding(.top, DS.Spacing.lg)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DS.Spacing.md) {
            StatCard(
                title: String(localized: "Duration"),
                value: summary.durationFormatted,
                systemImage: "clock"
            )
            StatCard(
                title: String(localized: "Total sets"),
                value: "\(summary.totalSets)",
                systemImage: "repeat"
            )
            StatCard(
                title: String(localized: "Total reps"),
                value: "\(summary.totalReps)",
                systemImage: "number"
            )
            StatCard(
                title: String(localized: "Total volume"),
                value: summary.totalVolume.formatted(.number.precision(.fractionLength(0))) + " kg",
                systemImage: "scalemass"
            )
        }
    }

    private var muscleBreakdownSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text(String(localized: "Volume by muscle"))
                .font(.headline)
                .foregroundStyle(.textPrimary)

            ForEach(
                summary.volumeByMuscle.values.sorted { $0.totalSets > $1.totalSets },
                id: \.muscleGroup
            ) { muscleSummary in
                MuscleVolumeRow(summary: muscleSummary)
            }
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }

    private var doneButton: some View {
        Button(action: onDone) {
            Text(String(localized: "Done"))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: DS.Sizing.minTapTarget)
        }
        .buttonStyle(.glassProminent)
        .tint(.accent)
    }
}

// MARK: - StatCard

private struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.accent)
            Text(verbatim: value)
                .font(.title2.weight(.bold).monospacedDigit())
                .foregroundStyle(.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Spacing.md)
        .cardStyle()
    }
}

// MARK: - MuscleVolumeRow

private struct MuscleVolumeRow: View {
    let summary: MuscleVolumeSummary

    var body: some View {
        HStack {
            MuscleGroupBadge(muscleGroup: summary.muscleGroup)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(localized: "\(summary.totalSets) sets"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                Text(verbatim: "\(summary.totalVolume.formatted(.number.precision(.fractionLength(0)))) kg")
                    .font(.caption2)
                    .foregroundStyle(.textSecondary)
            }
        }
    }
}

// MARK: - Previews

private struct PostWorkoutSummaryPreviewWrapper: View {
    @Environment(AppContainer.self) private var container
    @Query(filter: #Predicate<WorkoutSession> { $0.completedAt != nil })
    private var sessions: [WorkoutSession]

    var body: some View {
        if let session = sessions.first {
            NavigationStack {
                PostWorkoutSummaryView(
                    session: session,
                    volumeCalculatorService: container.volumeCalculatorService,
                    onDone: {}
                )
            }
        }
    }
}

#Preview(traits: .previewContainer(.withData)) {
    PostWorkoutSummaryPreviewWrapper()
}

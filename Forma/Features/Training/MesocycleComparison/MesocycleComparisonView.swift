//
//  MesocycleComparisonView.swift
//  Forma
//
//  Created by Armando Cáceres on 17/8/26.
//

import Charts
import SwiftData
import SwiftUI

struct MesocycleComparisonView: View {
    
    // MARK: - States
    
    @State private var viewModel: MesocycleComparisonViewModel
    @State private var showingVolumeInfo = false
    
    // MARK: - Initializers
    
    init(mesocycles: [Mesocycle], volumeCalculatorService: VolumeCalculatorServiceProtocol) {
        let interactor = MesocycleComparisonInteractor(volumeCalculatorService: volumeCalculatorService)
        _viewModel = State(initialValue: MesocycleComparisonViewModel(interactor: interactor, mesocycles: mesocycles))
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.xl) {
                weeklyVolumeSection
                adherenceSection
                muscleVolumeSection
            }
            .padding(DS.Spacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(.backgroundPrimary)
        .navigationTitle(String(localized: "Mesocycle comparison"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Private Computed Properties
    
    // Visual floor for zero-value bars so "0 kg this block" reads as a real bar, not a gap.
    private var weeklyVolumeMinimumVisibleValue: Double {
        weeklyVolumeMaxValue * 0.03
    }
    
    private var weeklyVolumeMaxValue: Double {
        viewModel.snapshot.entries.map(\.weeklyVolume).max() ?? 0
    }
    
    private var weeklyVolumeHasData: Bool {
        weeklyVolumeMaxValue > 0
    }
    
    // Visual floor for zero-value bars so "0 sets trained" reads as a real bar, not a gap.
    private var muscleChartMinimumVisibleValue: Double {
        muscleChartMaxSets * 0.03
    }
    
    private var muscleChartMaxSets: Double {
        viewModel.snapshot.entries
            .map { $0.volumeByMuscle[viewModel.selectedMuscle] ?? 0 }
            .max() ?? 0
    }
    
    private var muscleChartHasData: Bool {
        muscleChartMaxSets > 0
    }
    
    // MARK: - Private Views
    
    private var weeklyVolumeSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(String(localized: "Weekly volume"))
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    Text(String(localized: "Average kg per week"))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
                
                Spacer()
                
                Button {
                    showingVolumeInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel(String(localized: "About weekly volume"))
                .popover(isPresented: $showingVolumeInfo) {
                    Text(String(localized: "Mesocycles have different lengths, so we show the weekly average kg lifted instead of a raw total. That way, a 4-week block and an 8-week block compare fairly."))
                        .font(.subheadline)
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.leading)
                        .padding(DS.Spacing.lg)
                        .frame(width: 280)
                        .presentationCompactAdaptation(.popover)
                }
            }
            
            if weeklyVolumeHasData {
                Chart(viewModel.snapshot.entries) { entry in
                    let displayVolume = max(entry.weeklyVolume, weeklyVolumeMinimumVisibleValue)
                    BarMark(
                        x: .value(String(localized: "Mesocycle"), entry.name),
                        y: .value(String(localized: "Volume"), displayVolume)
                    )
                    .foregroundStyle(by: .value(String(localized: "Mesocycle"), entry.name))
                    .accessibilityLabel(entry.name)
                    .accessibilityValue(String(localized: "\(formattedVolume(entry.weeklyVolume)) kilograms per week"))
                }
                .chartLegend(position: .bottom, spacing: DS.Spacing.md)
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 4)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(Color.borderSubtle)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { mark in
                        AxisValueLabel {
                            if let value = mark.as(Double.self) {
                                Text(verbatim: value.formatted(.number.precision(.fractionLength(0))))
                                    .font(.caption2)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                        AxisGridLine().foregroundStyle(Color.borderSubtle)
                    }
                }
                .frame(height: 220)
            } else {
                emptyWeeklyVolumeChartPlaceholder
            }
        }
        .padding(DS.Spacing.lg)
        .cardStyle()
    }
    
    private var emptyWeeklyVolumeChartPlaceholder: some View {
        Text(String(localized: "None of the selected mesocycles logged any volume yet"))
            .font(.subheadline)
            .foregroundStyle(.textTertiary)
            .frame(maxWidth: .infinity, minHeight: 120)
            .multilineTextAlignment(.center)
    }
    
    private var adherenceSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text(String(localized: "Adherence"))
                .font(.headline)
                .foregroundStyle(.textPrimary)
            
            VStack(spacing: DS.Spacing.sm) {
                ForEach(viewModel.snapshot.entries) { entry in
                    MesocycleAdherenceRow(entry: entry)
                }
            }
        }
    }
    
    private var muscleVolumeSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(String(localized: "Volume by muscle"))
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    Text(String(localized: "Average sets per week"))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
                
                Spacer()
                
                Picker(String(localized: "Muscle group"), selection: $viewModel.selectedMuscle) {
                    ForEach(MuscleGroup.comparable, id: \.self) { muscle in
                        Text(muscle.localizedName).tag(muscle)
                    }
                }
                .pickerStyle(.menu)
            }
            
            if muscleChartHasData {
                Chart(viewModel.snapshot.entries) { entry in
                    let sets = entry.volumeByMuscle[viewModel.selectedMuscle] ?? 0
                    let displaySets = max(sets, muscleChartMinimumVisibleValue)
                    BarMark(
                        x: .value(String(localized: "Mesocycle"), entry.name),
                        y: .value(String(localized: "Sets"), displaySets)
                    )
                    .foregroundStyle(by: .value(String(localized: "Mesocycle"), entry.name))
                    .accessibilityLabel(entry.name)
                    .accessibilityValue(String(localized: "\(formattedSets(sets)) sets per week"))
                }
                .chartLegend(position: .bottom, spacing: DS.Spacing.md)
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 4)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(Color.borderSubtle)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { mark in
                        AxisValueLabel {
                            if let value = mark.as(Double.self) {
                                Text(verbatim: value.formatted(.number.precision(.fractionLength(1))))
                                    .font(.caption2)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                        AxisGridLine().foregroundStyle(Color.borderSubtle)
                    }
                }
                .frame(height: 220)
            } else {
                emptyMuscleChartPlaceholder
            }
        }
        .padding(DS.Spacing.lg)
        .cardStyle()
    }
    
    private var emptyMuscleChartPlaceholder: some View {
        Text(String(localized: "None of the selected mesocycles trained \(viewModel.selectedMuscle.localizedName)"))
            .font(.subheadline)
            .foregroundStyle(.textTertiary)
            .frame(maxWidth: .infinity, minHeight: 120)
            .multilineTextAlignment(.center)
    }
    
    // MARK: - Private Functions
    
    private func formattedVolume(_ volume: Double) -> String {
        volume.formatted(.number.precision(.fractionLength(0)))
    }
    
    private func formattedSets(_ sets: Double) -> String {
        sets.formatted(.number.precision(.fractionLength(1)))
    }
}

// MARK: - MesocycleAdherenceRow

private struct MesocycleAdherenceRow: View {
    
    let entry: MesocycleComparisonEntry
    
    private var adherenceLabel: String {
        guard entry.plannedSessions > 0 else { return String(localized: "No training days planned") }
        return String(localized: "\(entry.completedSessions) of \(entry.plannedSessions) sessions")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack(alignment: .top) {
                Text(entry.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: DS.Spacing.sm)
                
                if entry.isInProgress {
                    Text(String(localized: "In progress"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.accent)
                        .padding(.horizontal, DS.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Color.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            
            Text(adherenceLabel)
                .font(.caption)
                .foregroundStyle(.textSecondary)
            
            if let fraction = entry.adherenceFraction {
                ProgressView(value: min(fraction, 1))
                    .tint(.accent)
            }
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Previews

#Preview("With data", traits: .previewContainer(.empty)) {
    @Previewable @Environment(AppContainer.self) var container
    @Previewable @Environment(\.modelContext) var modelContext
    
    let older = Mesocycle(
        name: "Volumen Bloque 3",
        startDate: Calendar.current.date(byAdding: .weekOfYear, value: -12, to: .now)!,
        durationWeeks: 6,
        useFixedDays: false,
        isActive: false
    )
    let active = Mesocycle(
        name: "Hipertrofia Bloque 4",
        startDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: .now)!,
        durationWeeks: 6,
        useFixedDays: false,
        isActive: true
    )
    
    return NavigationStack {
        MesocycleComparisonView(
            mesocycles: [active, older],
            volumeCalculatorService: container.volumeCalculatorService
        )
    }
    .task {
        for mesocycle in [older, active] {
            modelContext.insert(mesocycle)
            let session = WorkoutSession()
            session.mesocycle = mesocycle
            session.completedAt = .now
            let samples: [(MuscleGroup, Int)] = [(.chest, 8), (.back, 12), (.shoulders, 6)]
            session.loggedSets = samples.flatMap { muscle, sets -> [LoggedSet] in
                let exercise = Exercise(name: "Exercise", primaryMuscle: muscle)
                let planned = PlannedExercise(order: 0)
                planned.exercise = exercise
                return (0..<sets).map { i in
                    let set = LoggedSet(order: i, exerciseName: exercise.name, weightKg: 40, reps: 10)
                    set.plannedExercise = planned
                    return set
                }
            }
            modelContext.insert(session)
            mesocycle.sessions.append(session)
        }
    }
}

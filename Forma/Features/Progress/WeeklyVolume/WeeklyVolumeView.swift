//
//  WeeklyVolumeView.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import SwiftData
import SwiftUI

struct WeeklyVolumeView: View {
    
    // MARK: - Private Properties
    
    @State private var viewModel: WeeklyVolumeViewModel
    @State private var showEditTargets = false
    @State private var showInfo = false
    
    // MARK: - Initializers
    
    init(
        sessionRepository: WorkoutSessionRepositoryProtocol,
        volumeCalculatorService: VolumeCalculatorServiceProtocol,
        targetRepository: MuscleVolumeTargetRepositoryProtocol
    ) {
        let interactor = WeeklyVolumeInteractor(
            sessionRepository: sessionRepository,
            volumeCalculatorService: volumeCalculatorService,
            targetRepository: targetRepository
        )
        _viewModel = State(initialValue: WeeklyVolumeViewModel(interactor: interactor))
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.snapshot == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let snapshot = viewModel.snapshot {
                contentView(snapshot)
            } else {
                Color.clear
            }
        }
        .navigationTitle(String(localized: "Weekly volume"))
        .background(.backgroundPrimary)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel(String(localized: "About MEV/MAV/MRV"))
                .popover(isPresented: $showInfo) {
                    Text(String(localized: "MEV: minimum effective volume. MAV: maximum adaptive volume. MRV: maximum recoverable volume."))
                        .font(.subheadline)
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.leading)
                        .padding(DS.Spacing.lg)
                        .frame(width: 280)
                        .presentationCompactAdaptation(.popover)
                }
            }
            
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditTargets = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel(String(localized: "Edit volume targets"))
            }
        }
        .sheet(isPresented: $showEditTargets) {
            NavigationStack {
                MuscleVolumeTargetsEditView(viewModel: viewModel)
            }
            .onDisappear {
                Task { await viewModel.load() }
            }
        }
        .alert(
            String(localized: "Error"),
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private func contentView(_ snapshot: WeeklyVolumeSnapshot) -> some View {
        if !snapshot.hasTargetsConfigured {
            setUpTargetsView
        } else if !snapshot.hasCompletedSessionsThisWeek {
            noSessionsThisWeekView
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                    Text(String(localized: "Partial progress for this week — check back after more sessions"))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                    
                    VStack(spacing: DS.Spacing.sm) {
                        ForEach(snapshot.coachings) { coaching in
                            MuscleVolumeCoachingRow(coaching: coaching)
                        }
                    }
                }
                .padding(DS.Spacing.lg)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var setUpTargetsView: some View {
        ContentUnavailableView {
            Label(String(localized: "Configure your volume targets"), systemImage: "chart.bar.fill")
        } description: {
            Text(String(localized: "Set MEV/MAV/MRV targets per muscle group to get weekly coaching"))
        } actions: {
            Button {
                Task { await viewModel.setUpDefaultTargets() }
            } label: {
                Text(String(localized: "Set up targets"))
                    .primaryButtonLabel()
            }
            .buttonStyle(.glassProminent)
            .tint(.accent)
            .disabled(viewModel.isSaving)
        }
    }
    
    private var noSessionsThisWeekView: some View {
        ContentUnavailableView {
            Label(String(localized: "You haven't trained this week yet"), systemImage: "calendar.badge.clock")
        } description: {
            Text(String(localized: "Complete a workout this week to see your volume coaching"))
        }
    }
}

// MARK: - MuscleVolumeCoachingRow

private struct MuscleVolumeCoachingRow: View {
    
    let coaching: MuscleVolumeCoaching
    
    private var stateColor: Color {
        switch coaching.state {
        case .belowMinimum:   .warning
        case .optimal:        .success
        case .approachingMax: .error
        case nil:             .textTertiary
        }
    }
    
    private var stateLabel: String {
        switch coaching.state {
        case .belowMinimum:   String(localized: "Below minimum")
        case .optimal:        String(localized: "Optimal range")
        case .approachingMax: String(localized: "Approaching maximum")
        case nil:             String(localized: "Not configured")
        }
    }
    
    private var progressFraction: Double {
        guard let target = coaching.target, target.mrvSets > 0 else { return 0 }
        return min(Double(coaching.actualSets) / Double(target.mrvSets), 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text(coaching.muscleGroup.localizedName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                
                Spacer()
                
                Text(stateLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(stateColor)
                    .padding(.horizontal, DS.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(stateColor.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            ProgressView(value: progressFraction)
                .tint(stateColor)
            
            HStack {
                Text(String(localized: "\(coaching.actualSets) sets"))
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                
                Spacer()
                
                if let target = coaching.target {
                    Text(verbatim: "MEV \(target.mevSets) · MAV \(target.mavSets) · MRV \(target.mrvSets)")
                        .font(.caption2)
                        .foregroundStyle(.textTertiary)
                }
            }
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }
}

#Preview("Empty", traits: .previewContainer(.empty)) {
    @Previewable @Environment(AppContainer.self) var container
    NavigationStack {
        WeeklyVolumeView(
            sessionRepository: container.workoutSessionRepository,
            volumeCalculatorService: container.volumeCalculatorService,
            targetRepository: container.muscleVolumeTargetRepository
        )
    }
}

#Preview("With data", traits: .previewContainer(.empty)) {
    @Previewable @Environment(AppContainer.self) var container
    @Previewable @Environment(\.modelContext) var modelContext
    NavigationStack {
        WeeklyVolumeView(
            sessionRepository: container.workoutSessionRepository,
            volumeCalculatorService: container.volumeCalculatorService,
            targetRepository: container.muscleVolumeTargetRepository
        )
    }
    .task {
        for muscle in MuscleGroup.allCases {
            let standard = MuscleVolumeStandards.values(for: muscle)
            modelContext.insert(MuscleVolumeTarget(muscleGroup: muscle, mevSets: standard.mev, mavSets: standard.mav, mrvSets: standard.mrv))
        }
        
        let session = WorkoutSession()
        session.completedAt = .now
        let samples: [(MuscleGroup, Int)] = [
            (.chest, 6), (.back, 20), (.shoulders, 18), (.biceps, 12), (.triceps, 20),
            (.quadriceps, 14), (.hamstrings, 10), (.glutes, 8), (.calves, 14), (.core, 6)
        ]
        session.loggedSets = samples.flatMap { muscle, sets -> [LoggedSet] in
            let exercise = Exercise(name: "Exercise", primaryMuscle: muscle)
            let planned = PlannedExercise(order: 0)
            planned.exercise = exercise
            return (0..<sets).map { i in
                let set = LoggedSet(order: i, exerciseName: exercise.name, weightKg: 20, reps: 10)
                set.plannedExercise = planned
                return set
            }
        }
        modelContext.insert(session)
    }
}

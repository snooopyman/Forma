//
//  ActiveSessionView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI
import SwiftData

struct ActiveSessionView: View {

    // MARK: - Private Properties

    private let volumeCalculatorService: VolumeCalculatorServiceProtocol
    private let onDone: () -> Void

    // MARK: - States

    @State private var viewModel: ActiveSessionViewModel
    @State private var elapsedTime: TimeInterval = 0
    @State private var showingSummary = false

    // MARK: - Initializers

    init(
        session: WorkoutSession,
        workoutDay: WorkoutDay,
        sessionService: WorkoutSessionServiceProtocol,
        volumeCalculatorService: VolumeCalculatorServiceProtocol,
        restTimerActivityService: RestTimerActivityServiceProtocol,
        healthKitService: HealthKitServiceProtocol,
        onDone: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: ActiveSessionViewModel(
            session: session,
            workoutDay: workoutDay,
            sessionService: sessionService,
            restTimerActivityService: restTimerActivityService,
            healthKitService: healthKitService
        ))
        self.volumeCalculatorService = volumeCalculatorService
        self.onDone = onDone
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sortedExercises.isEmpty {
                    ContentUnavailableView(
                        String(localized: "No exercises"),
                        systemImage: "exclamationmark.circle"
                    )
                } else {
                    sessionContent
                }
            }
            .navigationTitle(viewModel.workoutDay.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    elapsedTimeView
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            viewModel.showDiscardConfirmation = true
                        } label: {
                            Label(String(localized: "Discard workout"), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .navigationDestination(isPresented: $showingSummary) {
                PostWorkoutSummaryView(
                    session: viewModel.session,
                    volumeCalculatorService: volumeCalculatorService,
                    wasExportedToHealth: viewModel.wasExportedToHealth,
                    onDone: onDone
                )
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
        .alert(
            String(localized: "Finish workout?"),
            isPresented: Binding(
                get: { viewModel.showFinishConfirmation },
                set: { if !$0 { viewModel.showFinishConfirmation = false } }
            )
        ) {
            Button(String(localized: "Finish")) {
                Task {
                    await viewModel.completeSession()
                    if viewModel.isCompleted {
                        showingSummary = true
                    }
                }
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        }
        .alert(
            String(localized: "Discard workout?"),
            isPresented: Binding(
                get: { viewModel.showDiscardConfirmation },
                set: { if !$0 { viewModel.showDiscardConfirmation = false } }
            )
        ) {
            Button(String(localized: "Discard"), role: .destructive) {
                Task {
                    await viewModel.discardSession()
                    onDone()
                }
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                elapsedTime = Date.now.timeIntervalSince(viewModel.session.startedAt)
            }
        }
        .sensoryFeedback(.impact(weight: .heavy, intensity: 0.8), trigger: viewModel.isResting) { _, new in
            new == true
        }
        .sensoryFeedback(.success, trigger: viewModel.restJustEnded) { _, new in
            new == true
        }
        .onChange(of: viewModel.restJustEnded) { _, new in
            if new { viewModel.restJustEnded = false }
        }
    }

    // MARK: - Private Views

    private var elapsedTimeView: some View {
        Text(Duration.seconds(Int(elapsedTime)).formatted(.time(pattern: .minuteSecond)))
            .font(.body.monospacedDigit())
            .foregroundStyle(.textSecondary)
    }

    @ViewBuilder
    private var sessionContent: some View {
        VStack(spacing: 0) {
            exerciseNavigationHeader

            if let exercise = viewModel.currentExercise {
                exerciseView(exercise: exercise)
            } else {
                ContentUnavailableView(
                    String(localized: "No exercises"),
                    systemImage: "exclamationmark.circle"
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                if viewModel.isResting {
                    restTimerBanner
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                finishButton
                    .padding(DS.Spacing.lg)
            }
            .animation(.spring(duration: 0.3), value: viewModel.isResting)
        }
    }

    private var exerciseNavigationHeader: some View {
        HStack {
            Button {
                viewModel.navigatePrevious()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .frame(minWidth: DS.Sizing.minTapTarget, minHeight: DS.Sizing.minTapTarget)
            }
            .disabled(!viewModel.canNavigatePrevious)
            .opacity(viewModel.canNavigatePrevious ? 1 : 0.3)

            Spacer()

            Text(verbatim: "\(viewModel.currentExerciseIndex + 1) / \(viewModel.sortedExercises.count)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.textSecondary)

            Spacer()

            Button {
                viewModel.navigateNext()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .frame(minWidth: DS.Sizing.minTapTarget, minHeight: DS.Sizing.minTapTarget)
            }
            .disabled(!viewModel.canNavigateNext)
            .opacity(viewModel.canNavigateNext ? 1 : 0.3)
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, DS.Spacing.sm)
    }

    @ViewBuilder
    private func exerciseView(exercise: PlannedExercise) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                exerciseHeader(exercise: exercise)
                loggedSetsSection(exercise: exercise)
                inputSection(exercise: exercise)
            }
            .padding(DS.Spacing.lg)
        }
        .task(id: exercise.id) {
            await viewModel.loadLastWeight(for: exercise)
        }
    }

    private func exerciseHeader(exercise: PlannedExercise) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(exercise.exercise?.name ?? "—")
                .font(.title.weight(.bold))
                .foregroundStyle(.textPrimary)
            HStack(spacing: DS.Spacing.sm) {
                if let muscle = exercise.exercise?.primaryMuscle {
                    MuscleGroupBadge(muscleGroup: muscle)
                }
                Text(verbatim: "\(exercise.sets) × \(exercise.repsMin)–\(exercise.repsMax) · RIR \(exercise.rirTarget)")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func loggedSetsSection(exercise: PlannedExercise) -> some View {
        let logged = viewModel.loggedSets(for: exercise)
        if !logged.isEmpty {
            VStack(spacing: DS.Spacing.sm) {
                ForEach(logged) { set in
                    ExerciseSetRow(
                        setNumber: set.order,
                        targetReps: set.reps,
                        targetWeight: set.weightKg,
                        rir: set.rirActual ?? exercise.rirTarget,
                        state: .completed,
                        onComplete: {}
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteSet(set) }
                        } label: {
                            Label(String(localized: "Delete"), systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func inputSection(exercise: PlannedExercise) -> some View {
        let loggedCount = viewModel.loggedSets(for: exercise).count
        if loggedCount < exercise.sets {
            VStack(spacing: DS.Spacing.md) {
                Text(verbatim: String(localized: "Set") + " \(viewModel.nextSetNumber(for: exercise))")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: DS.Spacing.md) {
                    weightField(exercise: exercise)
                    repsField(exercise: exercise)
                    rirField(exercise: exercise)
                }

                Button {
                    Task { await viewModel.logSet(for: exercise) }
                } label: {
                    Text(String(localized: "Log set"))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: DS.Sizing.minTapTarget)
                }
                .buttonStyle(.glassProminent)
                .tint(.accent)
            }
            .padding(DS.Spacing.md)
            .cardStyle()
        } else if viewModel.canNavigateNext {
            Button {
                viewModel.navigateNext()
            } label: {
                Label(String(localized: "Next exercise"), systemImage: "arrow.right")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: DS.Sizing.minTapTarget)
            }
            .buttonStyle(.glassProminent)
            .tint(.accent)
        } else {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.success)
                Text(String(localized: "All sets done"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(DS.Spacing.md)
            .cardStyle()
        }
    }

    private func weightField(exercise: PlannedExercise) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(String(localized: "Weight"))
                .font(.caption)
                .foregroundStyle(.textSecondary)
            HStack(spacing: DS.Spacing.xs) {
                Button {
                    adjustWeight(by: -2.5, for: exercise)
                } label: {
                    Text(verbatim: "−2.5")
                        .font(.caption.weight(.medium))
                        .frame(minWidth: DS.Sizing.minTapTarget, minHeight: DS.Sizing.minTapTarget)
                        .background(.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.inner))
                }
                TextField(
                    text: Binding(
                        get: { viewModel.weightInputs[exercise.id] ?? "" },
                        set: { viewModel.weightInputs[exercise.id] = $0 }
                    ),
                    prompt: Text(verbatim: "0")
                ) {}
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.title2.weight(.bold).monospacedDigit())
                .frame(minWidth: 60)
                Button {
                    adjustWeight(by: 2.5, for: exercise)
                } label: {
                    Text(verbatim: "+2.5")
                        .font(.caption.weight(.medium))
                        .frame(minWidth: DS.Sizing.minTapTarget, minHeight: DS.Sizing.minTapTarget)
                        .background(.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.inner))
                }
            }
            Text(verbatim: "kg")
                .font(.caption2)
                .foregroundStyle(.textTertiary)
        }
    }

    private func repsField(exercise: PlannedExercise) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(String(localized: "Reps"))
                .font(.caption)
                .foregroundStyle(.textSecondary)
            TextField(
                text: Binding(
                    get: { viewModel.repsInputs[exercise.id] ?? "" },
                    set: { viewModel.repsInputs[exercise.id] = $0 }
                ),
                prompt: Text(verbatim: "\(exercise.repsMin)")
            ) {}
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.title2.weight(.bold).monospacedDigit())
            .frame(minHeight: DS.Sizing.minTapTarget)
            Text(verbatim: "reps")
                .font(.caption2)
                .foregroundStyle(.textTertiary)
        }
    }

    private func rirField(exercise: PlannedExercise) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(verbatim: "RIR")
                .font(.caption)
                .foregroundStyle(.textSecondary)
            TextField(
                text: Binding(
                    get: { viewModel.rirInputs[exercise.id] ?? "" },
                    set: { viewModel.rirInputs[exercise.id] = $0 }
                ),
                prompt: Text(verbatim: "\(exercise.rirTarget)")
            ) {}
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.title2.weight(.bold).monospacedDigit())
            .frame(minHeight: DS.Sizing.minTapTarget)
            Text(verbatim: " ")
                .font(.caption2)
        }
    }

    private var restTimerBanner: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(.accent)
            Text(Duration.seconds(viewModel.restSecondsRemaining).formatted(.time(pattern: .minuteSecond)))
                .font(.body.weight(.semibold).monospacedDigit())
                .foregroundStyle(.textPrimary)
            Spacer()
            Button(String(localized: "Skip")) {
                viewModel.skipRest()
            }
            .font(.body.weight(.medium))
            .foregroundStyle(.accent)
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, DS.Spacing.md)
        .background(.backgroundCard)
    }

    private var finishButton: some View {
        Button {
            viewModel.showFinishConfirmation = true
        } label: {
            Text(String(localized: "Finish workout"))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: DS.Sizing.minTapTarget)
        }
        .buttonStyle(.glassProminent)
        .tint(.success)
        .disabled(viewModel.isCompleting)
    }

    // MARK: - Private Functions

    private func adjustWeight(by delta: Double, for exercise: PlannedExercise) {
        let current = (viewModel.weightInputs[exercise.id] ?? "0").weightDouble ?? 0
        let newValue = max(0, current + delta)
        viewModel.weightInputs[exercise.id] = newValue.asWeight
    }
}

// MARK: - Previews

private struct ActiveSessionPreviewWrapper: View {
    @Environment(AppContainer.self) private var container
    @Query private var sessions: [WorkoutSession]
    @Query private var days: [WorkoutDay]

    var body: some View {
        if let day = days.first(where: { !$0.isRestDay }),
           let session = sessions.first(where: { !$0.isCompleted }) {
            ActiveSessionView(
                session: session,
                workoutDay: day,
                sessionService: container.workoutSessionService,
                volumeCalculatorService: container.volumeCalculatorService,
                restTimerActivityService: container.restTimerActivityService,
                healthKitService: container.healthKitService,
                onDone: {}
            )
        }
    }
}

#Preview(traits: .previewContainer(.withData)) {
    ActiveSessionPreviewWrapper()
}

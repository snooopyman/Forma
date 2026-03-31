//
//  WorkoutDayDetailView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI
import SwiftData

struct WorkoutDayDetailView: View {

    // MARK: - Private Properties

    private let mesocycleRepository: MesocycleRepositoryProtocol

    // MARK: - States

    @State private var viewModel: WorkoutDayDetailViewModel
    @State private var activeSession: WorkoutSession?
    @State private var showingAddExercise = false

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - Initializers

    init(
        workoutDay: WorkoutDay,
        mesocycleRepository: MesocycleRepositoryProtocol,
        sessionService: WorkoutSessionServiceProtocol,
        sessionRepository: WorkoutSessionRepositoryProtocol
    ) {
        self.mesocycleRepository = mesocycleRepository
        _viewModel = State(initialValue: WorkoutDayDetailViewModel(
            workoutDay: workoutDay,
            sessionService: sessionService,
            sessionRepository: sessionRepository
        ))
    }

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                contentView
            }
        }
        .navigationTitle(viewModel.workoutDay.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !viewModel.workoutDay.isRestDay {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddPlannedExerciseView(
                workoutDay: viewModel.workoutDay,
                mesocycleRepository: mesocycleRepository
            )
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
        .fullScreenCover(item: $activeSession) { session in
            ActiveSessionView(
                session: session,
                workoutDay: viewModel.workoutDay,
                sessionService: container.workoutSessionService,
                volumeCalculatorService: container.volumeCalculatorService,
                onDone: { activeSession = nil }
            )
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        if viewModel.workoutDay.isRestDay {
            restDayView
        } else {
            exercisesListView
        }
    }

    private var restDayView: some View {
        ContentUnavailableView(
            String(localized: "Rest day"),
            systemImage: "moon.zzz.fill",
            description: viewModel.workoutDay.restDayActivity.isEmpty
                ? nil
                : Text(viewModel.workoutDay.restDayActivity)
        )
    }

    @ViewBuilder
    private var exercisesListView: some View {
        if viewModel.sortedExercises.isEmpty {
            ContentUnavailableView(
                String(localized: "No exercises configured"),
                systemImage: "dumbbell",
                description: Text(String(localized: "Tap + to add your first exercise"))
            )
        } else {
            List {
                ForEach(viewModel.sortedExercises) { planned in
                    PlannedExerciseRowView(planned: planned)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if viewModel.canStartSession {
                    startButton
                        .padding(DS.Spacing.lg)
                } else if let inProgress = viewModel.inProgressSession,
                          inProgress.workoutDay?.id == viewModel.workoutDay.id {
                    resumeButton(session: inProgress)
                        .padding(DS.Spacing.lg)
                }
            }
        }
    }

    private var startButton: some View {
        Button {
            Task {
                do {
                    let session = try await viewModel.startSession()
                    activeSession = session
                } catch {
                    viewModel.errorMessage = String(localized: "Something went wrong")
                }
            }
        } label: {
            Group {
                if viewModel.isStarting {
                    ProgressView()
                } else {
                    Text(String(localized: "Start workout"))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: DS.Sizing.minTapTarget)
                }
            }
        }
        .buttonStyle(.glassProminent)
        .tint(.accent)
        .disabled(viewModel.isStarting)
    }

    private func resumeButton(session: WorkoutSession) -> some View {
        Button {
            activeSession = session
        } label: {
            Text(String(localized: "Resume session"))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: DS.Sizing.minTapTarget)
        }
        .buttonStyle(.glass)
        .tint(.success)
    }
}

// MARK: - PlannedExerciseRowView

private struct PlannedExerciseRowView: View {
    let planned: PlannedExercise

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text(planned.exercise?.name ?? "—")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.textPrimary)
                Spacer()
                if let muscle = planned.exercise?.primaryMuscle {
                    MuscleGroupBadge(muscleGroup: muscle)
                }
            }
            HStack(spacing: DS.Spacing.md) {
                Label {
                    Text(verbatim: "\(planned.sets) × \(planned.repsMin)–\(planned.repsMax)")
                } icon: {
                    Image(systemName: "repeat")
                }
                .font(.caption)
                .foregroundStyle(.textSecondary)

                Label {
                    Text(verbatim: "RIR \(planned.rirTarget)")
                } icon: {
                    Image(systemName: "gauge.medium")
                }
                .font(.caption)
                .foregroundStyle(.textSecondary)

                Label {
                    Text(verbatim: "\(planned.restSeconds)s")
                } icon: {
                    Image(systemName: "timer")
                }
                .font(.caption)
                .foregroundStyle(.textSecondary)
            }
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - Previews

private struct WorkoutDayDetailPreviewWrapper: View {
    @Environment(AppContainer.self) private var container
    @Query private var days: [WorkoutDay]

    var body: some View {
        if let day = days.first(where: { !$0.isRestDay }) {
            NavigationStack {
                WorkoutDayDetailView(
                    workoutDay: day,
                    mesocycleRepository: container.mesocycleRepository,
                    sessionService: container.workoutSessionService,
                    sessionRepository: container.workoutSessionRepository
                )
            }
        }
    }
}

#Preview(traits: .previewContainer(.withData)) {
    WorkoutDayDetailPreviewWrapper()
}

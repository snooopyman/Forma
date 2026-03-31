//
//  MesocycleDetailView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI
import SwiftData

struct MesocycleDetailView: View {

    // MARK: - States

    @State private var viewModel: MesocycleDetailViewModel
    @State private var showingCreateDay = false

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - Initializers

    init(
        mesocycle: Mesocycle,
        mesocycleRepository: MesocycleRepositoryProtocol,
        sessionRepository: WorkoutSessionRepositoryProtocol
    ) {
        _viewModel = State(initialValue: MesocycleDetailViewModel(
            mesocycle: mesocycle,
            mesocycleRepository: mesocycleRepository,
            sessionRepository: sessionRepository
        ))
    }

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.sessions.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                contentView
            }
        }
        .navigationTitle(viewModel.mesocycle.name)
        .navigationBarTitleDisplayMode(.large)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateDay = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateDay) {
            CreateWorkoutDayView(mesocycle: viewModel.mesocycle, mesocycleRepository: container.mesocycleRepository)
        }
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        List {
            statusSection
            daysSection
        }
        .navigationDestination(for: WorkoutDay.self) { day in
            WorkoutDayDetailView(
                workoutDay: day,
                mesocycleRepository: container.mesocycleRepository,
                sessionService: container.workoutSessionService,
                sessionRepository: container.workoutSessionRepository
            )
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("\(viewModel.mesocycle.durationWeeks) weeks")
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                    Text("Week \(viewModel.mesocycle.currentWeek) of \(viewModel.mesocycle.durationWeeks)")
                        .font(.body.weight(.semibold))
                }
                Spacer()
                statusControlMenu
            }
        }
    }

    @ViewBuilder
    private var statusControlMenu: some View {
        Menu {
            if !viewModel.mesocycle.isActive {
                Button {
                    Task { await viewModel.activate() }
                } label: {
                    Label(String(localized: "Set as active"), systemImage: "checkmark.circle")
                }
            }
            if viewModel.mesocycle.isActive && !viewModel.mesocycle.isPaused {
                Button {
                    Task { await viewModel.pause() }
                } label: {
                    Label(String(localized: "Pause"), systemImage: "pause.circle")
                }
            }
            if viewModel.mesocycle.isPaused {
                Button {
                    Task { await viewModel.resume() }
                } label: {
                    Label(String(localized: "Resume"), systemImage: "play.circle")
                }
            }
        } label: {
            Image(systemName: viewModel.mesocycle.isActive ? "bolt.fill" : "ellipsis.circle")
                .foregroundStyle(viewModel.mesocycle.isActive ? .accent : .textSecondary)
        }
    }

    @ViewBuilder
    private var daysSection: some View {
        Section(String(localized: "Workout days")) {
            if viewModel.sortedWorkoutDays.isEmpty {
                Text(String(localized: "No workout days configured"))
                    .foregroundStyle(.textSecondary)
            } else {
                ForEach(viewModel.sortedWorkoutDays) { day in
                    NavigationLink(value: day) {
                        WorkoutDayRowView(
                            day: day,
                            completedCount: viewModel.completedSessionCount(for: day)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - WorkoutDayRowView

private struct WorkoutDayRowView: View {
    let day: WorkoutDay
    let completedCount: Int

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(day.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.textPrimary)
                if day.isRestDay {
                    Text(String(localized: "Rest day"))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                } else {
                    HStack(spacing: DS.Spacing.xs) {
                        if let weekday = day.weekday {
                            Text(weekday.shortName)
                                .font(.caption)
                                .foregroundStyle(.accent)
                        }
                        Text(verbatim: "\(day.plannedExercises.count) \(String(localized: "exercises"))")
                            .font(.caption)
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
            Spacer()
            if completedCount > 0 {
                Text(verbatim: "\(completedCount)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.success)
            }
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - Previews

private struct MesocycleDetailPreviewWrapper: View {
    @Environment(AppContainer.self) private var container
    @Query private var mesocycles: [Mesocycle]

    var body: some View {
        if let first = mesocycles.first {
            NavigationStack {
                MesocycleDetailView(
                    mesocycle: first,
                    mesocycleRepository: container.mesocycleRepository,
                    sessionRepository: container.workoutSessionRepository
                )
            }
        }
    }
}

#Preview(traits: .previewContainer(.withData)) {
    MesocycleDetailPreviewWrapper()
}

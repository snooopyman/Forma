//
//  MesocycleListView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct MesocycleListView: View {

    // MARK: - States

    @State private var viewModel: MesocycleListViewModel
    @State private var showingCreate = false

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - Initializers

    init(mesocycleRepository: MesocycleRepositoryProtocol) {
        _viewModel = State(initialValue: MesocycleListViewModel(mesocycleRepository: mesocycleRepository))
    }

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.mesocycles.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.mesocycles.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle(String(localized: "Training"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreate) {
            CreateMesocycleView {
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
            Button(String(localized: "Retry")) {
                Task { await viewModel.load() }
            }
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
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
            ForEach(viewModel.mesocycles) { mesocycle in
                NavigationLink(value: mesocycle) {
                    MesocycleRowView(mesocycle: mesocycle)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task { await viewModel.delete(mesocycle) }
                    } label: {
                        Label(String(localized: "Delete"), systemImage: "trash")
                    }
                    if !mesocycle.isActive {
                        Button {
                            Task { await viewModel.setActive(mesocycle) }
                        } label: {
                            Label(String(localized: "Set active"), systemImage: "checkmark.circle")
                        }
                        .tint(.green)
                    }
                }
            }
        }
        .navigationDestination(for: Mesocycle.self) { mesocycle in
            MesocycleDetailView(
                mesocycle: mesocycle,
                mesocycleRepository: container.mesocycleRepository,
                sessionRepository: container.workoutSessionRepository
            )
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            String(localized: "No mesocycles yet"),
            systemImage: "figure.strengthtraining.traditional",
            description: Text(String(localized: "Tap + to create your first mesocycle"))
        )
    }
}

// MARK: - MesocycleRowView

private struct MesocycleRowView: View {
    let mesocycle: Mesocycle

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack {
                Text(mesocycle.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                Spacer()
                statusBadge
            }
            Text("Week \(mesocycle.currentWeek) of \(mesocycle.durationWeeks)")
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .padding(.vertical, DS.Spacing.xs)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if mesocycle.isActive {
            Label(String(localized: "Active"), systemImage: "bolt.fill")
                .font(.caption.weight(.medium))
                .foregroundStyle(.accent)
        } else if mesocycle.isPaused {
            Label(String(localized: "Paused"), systemImage: "pause.fill")
                .font(.caption.weight(.medium))
                .foregroundStyle(.textSecondary)
        }
    }
}

// MARK: - Previews

private struct MesocycleListPreviewWrapper: View {
    @Environment(AppContainer.self) private var container
    var body: some View {
        NavigationStack {
            MesocycleListView(mesocycleRepository: container.mesocycleRepository)
        }
    }
}

#Preview(traits: .previewContainer(.withData)) {
    MesocycleListPreviewWrapper()
}

#Preview("Vacío", traits: .previewContainer(.empty)) {
    MesocycleListPreviewWrapper()
}

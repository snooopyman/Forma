//
//  MesocycleListView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct MesocycleListView: View {
    
    // MARK: - Environment
    
    @Environment(AppContainer.self) private var container
    @Environment(\.mesocycleListViewModel) private var viewModel
    
    // MARK: - States
    
    @AppStorage("postOnboardingAction") private var postOnboardingAction: AppTab = .today
    @State private var showingCreate = false
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let viewModel {
                mainContent(viewModel)
            } else {
                contentView(MockMesocycleListViewModel.withData)
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
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
                Task { await viewModel?.load() }
            }
        }
        .task {
            await viewModel?.load()
        }
        .onAppear {
            if postOnboardingAction == .training {
                postOnboardingAction = .today
                showingCreate = true
            }
        }
        .refreshable {
            await viewModel?.load()
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private func mainContent(_ viewModel: any MesocycleListViewModelProtocol) -> some View {
        Group {
            if viewModel.isLoading && viewModel.mesocycles.isEmpty {
                contentView(MockMesocycleListViewModel.withData)
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
            } else if viewModel.mesocycles.isEmpty {
                emptyView
            } else {
                contentView(viewModel)
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
    }
    
    @ViewBuilder
    private func contentView(_ viewModel: any MesocycleListViewModelProtocol) -> some View {
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
                        .tint(.success)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(.backgroundPrimary)
        .navigationDestination(for: Mesocycle.self) { mesocycle in
            MesocycleDetailView(
                mesocycle: mesocycle,
                mesocycleRepository: container.mesocycleRepository,
                sessionRepository: container.workoutSessionRepository
            )
        }
    }
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label(String(localized: "No mesocycles yet"), systemImage: "figure.strengthtraining.traditional")
        } description: {
            Text(String(localized: "Create your first mesocycle to build a structured training routine"))
        } actions: {
            Button {
                showingCreate = true
            } label: {
                Text(String(localized: "Create mesocycle"))
                    .primaryButtonLabel()
            }
            .buttonStyle(.glassProminent)
            .tint(.accent)
        }
    }
}

// MARK: - MesocycleRowView

private struct MesocycleRowView: View {
    let mesocycle: Mesocycle
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack(alignment: .top) {
                Text(mesocycle.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: DS.Spacing.sm)
                statusBadge
            }
            Text(String(localized: "Week \(mesocycle.currentWeek) of \(mesocycle.durationWeeks)"))
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

#Preview("Empty", traits: .previewContainer(.empty)) {
    NavigationStack { MesocycleListView() }
        .environment(\.mesocycleListViewModel, MockMesocycleListViewModel.empty)
}

#Preview("With data", traits: .previewContainer(.withData)) {
    NavigationStack { MesocycleListView() }
        .environment(\.mesocycleListViewModel, MockMesocycleListViewModel.withData)
}

#Preview("Loading", traits: .previewContainer(.empty)) {
    NavigationStack { MesocycleListView() }
        .environment(\.mesocycleListViewModel, MockMesocycleListViewModel.loading)
}

#Preview("Error", traits: .previewContainer(.empty)) {
    NavigationStack { MesocycleListView() }
        .environment(\.mesocycleListViewModel, MockMesocycleListViewModel.withError)
}

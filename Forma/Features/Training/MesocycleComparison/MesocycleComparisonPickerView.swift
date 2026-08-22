//
//  MesocycleComparisonPickerView.swift
//  Forma
//
//  Created by Armando Cáceres on 17/8/26.
//

import SwiftUI

struct MesocycleComparisonPickerView: View {

    // MARK: - Private Properties

    private let volumeCalculatorService: VolumeCalculatorServiceProtocol

    // MARK: - States

    @State private var selectedIDs: Set<UUID> = []
    @State private var showingComparison = false

    // MARK: - Properties

    let mesocycles: [Mesocycle]

    // MARK: - Computed Properties

    private var eligibleMesocycles: [Mesocycle] {
        mesocycles.filter { $0.sessions.contains { $0.isCompleted } }
    }

    private var selectedMesocycles: [Mesocycle] {
        eligibleMesocycles.filter { selectedIDs.contains($0.id) }
    }

    // MARK: - Initializers

    init(mesocycles: [Mesocycle], volumeCalculatorService: VolumeCalculatorServiceProtocol) {
        self.mesocycles = mesocycles
        self.volumeCalculatorService = volumeCalculatorService
    }

    // MARK: - Body

    var body: some View {
        List(eligibleMesocycles) { mesocycle in
            row(for: mesocycle)
        }
        .scrollContentBackground(.hidden)
        .background(.backgroundPrimary)
        .navigationTitle(String(localized: "Compare mesocycles"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "Compare")) {
                    showingComparison = true
                }
                .disabled(selectedIDs.count < 2)
            }
        }
        .navigationDestination(isPresented: $showingComparison) {
            MesocycleComparisonView(
                mesocycles: selectedMesocycles,
                volumeCalculatorService: volumeCalculatorService
            )
        }
    }

    // MARK: - Private Views

    private func row(for mesocycle: Mesocycle) -> some View {
        let isSelected = selectedIDs.contains(mesocycle.id)
        return Button {
            toggle(mesocycle)
        } label: {
            HStack {
                Text(mesocycle.name)
                    .foregroundStyle(.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Private Functions

    private func toggle(_ mesocycle: Mesocycle) {
        if selectedIDs.contains(mesocycle.id) {
            selectedIDs.remove(mesocycle.id)
        } else {
            selectedIDs.insert(mesocycle.id)
        }
    }
}

// MARK: - Previews

#Preview("With data", traits: .previewContainer(.empty)) {
    @Previewable @Environment(AppContainer.self) var container

    let older = Mesocycle(
        name: "Volumen Bloque 3",
        startDate: Calendar.current.date(byAdding: .weekOfYear, value: -12, to: .now)!,
        durationWeeks: 6
    )
    older.sessions = [{
        let session = WorkoutSession()
        session.completedAt = .now
        return session
    }()]

    let active = Mesocycle(
        name: "Hipertrofia Bloque 4",
        startDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: .now)!,
        durationWeeks: 6,
        isActive: true
    )
    active.sessions = [{
        let session = WorkoutSession()
        session.completedAt = .now
        return session
    }()]

    let notEligible = Mesocycle(name: "Recién creado")

    return NavigationStack {
        MesocycleComparisonPickerView(
            mesocycles: [older, active, notEligible],
            volumeCalculatorService: container.volumeCalculatorService
        )
    }
}

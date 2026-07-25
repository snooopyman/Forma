//
//  MuscleVolumeTargetsEditView.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import SwiftData
import SwiftUI

struct MuscleVolumeTargetsEditView: View {
    
    // MARK: - Properties
    
    @Bindable var viewModel: WeeklyVolumeViewModel
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.sortedTargets) { target in
                    MuscleVolumeTargetRow(target: target) {
                        Task { await viewModel.save(target) }
                    }
                }
            } footer: {
                Text(String(localized: "MEV: minimum effective volume. MAV: maximum adaptive volume. MRV: maximum recoverable volume."))
            }
            
            Section {
                Button {
                    Task { await viewModel.restoreDefaultTargets() }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text(String(localized: "Restore standard values"))
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
        .navigationTitle(String(localized: "Volume targets"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Done")) { dismiss() }
            }
        }
        .task { await viewModel.loadTargets() }
    }
}

// MARK: - MuscleVolumeTargetRow

private struct MuscleVolumeTargetRow: View {
    
    // MARK: - Properties
    
    @Bindable var target: MuscleVolumeTarget
    let onChange: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(target.muscleGroup.localizedName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
            
            Stepper(value: $target.mevSets, in: 0...40) {
                LabeledContent(String(localized: "MEV"), value: target.mevSets, format: .number)
            }
            .onChange(of: target.mevSets) { onChange() }
            
            Stepper(value: $target.mavSets, in: 0...40) {
                LabeledContent(String(localized: "MAV"), value: target.mavSets, format: .number)
            }
            .onChange(of: target.mavSets) { onChange() }
            
            Stepper(value: $target.mrvSets, in: 0...40) {
                LabeledContent(String(localized: "MRV"), value: target.mrvSets, format: .number)
            }
            .onChange(of: target.mrvSets) { onChange() }
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

#Preview("With data", traits: .previewContainer(.empty)) {
    @Previewable @Environment(AppContainer.self) var container
    @Previewable @Environment(\.modelContext) var modelContext
    NavigationStack {
        MuscleVolumeTargetsEditView(
            viewModel: WeeklyVolumeViewModel(interactor: WeeklyVolumeInteractor(
                sessionRepository: container.workoutSessionRepository,
                volumeCalculatorService: container.volumeCalculatorService,
                targetRepository: container.muscleVolumeTargetRepository
            ))
        )
    }
    .task {
        for muscle in MuscleGroup.allCases {
            let standard = MuscleVolumeStandards.values(for: muscle)
            modelContext.insert(MuscleVolumeTarget(muscleGroup: muscle, mevSets: standard.mev, mavSets: standard.mav, mrvSets: standard.mrv))
        }
    }
}

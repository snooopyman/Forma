//
//  NewMeasurementView.swift
//  Forma
//
//  Created by Armando Cáceres on 5/4/26.
//

import SwiftUI

struct NewMeasurementView: View {

    // MARK: - Private Properties

    @State private var viewModel: NewMeasurementViewModel
    @State private var showReplaceAlert = false

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Initializers

    init(
        repository: BodyMeasurementRepositoryProtocol,
        profileRepository: UserProfileRepositoryProtocol,
        healthKitService: HealthKitServiceProtocol,
        measurementReminderScheduler: MeasurementReminderSchedulerProtocol,
        existingMeasurements: [BodyMeasurement] = [],
        editing: BodyMeasurement? = nil,
        onSaved: @escaping @MainActor () -> Void
    ) {
        let interactor = NewMeasurementInteractor(
            measurementRepository: repository,
            profileRepository: profileRepository,
            healthKitService: healthKitService,
            measurementReminderScheduler: measurementReminderScheduler
        )
        _viewModel = State(initialValue: NewMeasurementViewModel(
            interactor: interactor,
            existingMeasurements: existingMeasurements,
            editing: editing,
            onSaved: onSaved
        ))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        String(localized: "Date"),
                        selection: $viewModel.date,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                } footer: {
                    if viewModel.duplicateMeasurement != nil {
                        Text(String(localized: "You already have a measurement this week. Saving will replace it."))
                            .foregroundStyle(.warning)
                    }
                }

                Section(String(localized: "Weight")) {
                    MeasurementField(
                        label: String(localized: "Weight"),
                        unit: "kg",
                        text: $viewModel.weightText
                    )
                }

                Section {
                    MeasurementField(label: String(localized: "Neck"), unit: "cm", text: $viewModel.neckText)
                    MeasurementField(label: String(localized: "Arm"), unit: "cm", text: $viewModel.armText)
                    MeasurementField(label: String(localized: "Waist"), unit: "cm", text: $viewModel.waistText)
                    MeasurementField(label: String(localized: "Abdomen"), unit: "cm", text: $viewModel.abdomenText)
                    MeasurementField(label: String(localized: "Pelvis"), unit: "cm", text: $viewModel.pelvisText)
                    MeasurementField(label: String(localized: "Thigh"), unit: "cm", text: $viewModel.thighText)
                } header: {
                    Text(String(localized: "Circumferences"))
                } footer: {
                    Text(String(localized: "Neck and abdomen are required to calculate body fat %"))
                }

                Section(String(localized: "Notes")) {
                    TextField(String(localized: "Optional notes"), text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section {
                    DisclosureGroup(String(localized: "Advanced")) {
                        MeasurementField(
                            label: String(localized: "Height"),
                            unit: "cm",
                            text: $viewModel.heightText
                        )
                    }
                } footer: {
                    Text(String(localized: "Height is used to calculate BMI and body fat %"))
                }
            }
            .task { await viewModel.loadProfileHeight() }
            .navigationTitle(viewModel.isEditing ? String(localized: "Edit measurement") : String(localized: "New measurement"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        if viewModel.duplicateMeasurement != nil {
                            showReplaceAlert = true
                        } else {
                            Task {
                                await viewModel.save()
                                if viewModel.errorMessage == nil {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
            .alert(String(localized: "Replace measurement?"), isPresented: $showReplaceAlert) {
                Button(String(localized: "Replace"), role: .destructive) {
                    Task {
                        await viewModel.save(replacing: viewModel.duplicateMeasurement)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                Button(L10n.Common.cancel, role: .cancel) {}
            } message: {
                Text(String(localized: "You already have a measurement for this week. Do you want to replace it?"))
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
        }
    }
}

// MARK: - MeasurementField

private struct MeasurementField: View {

    let label: String
    let unit: String
    @Binding var text: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(unit)
                .foregroundStyle(.textSecondary)
                .frame(width: 28, alignment: .leading)
        }
    }
}

#Preview(traits: .previewContainer()) {
    @Previewable @Environment(AppContainer.self) var container
    NewMeasurementView(
        repository: container.bodyMeasurementRepository,
        profileRepository: container.userProfileRepository,
        healthKitService: container.healthKitService,
        measurementReminderScheduler: container.measurementReminderScheduler,
        onSaved: {}
    )
}

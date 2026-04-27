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

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Initializers

    init(
        repository: BodyMeasurementRepositoryProtocol,
        profileRepository: UserProfileRepositoryProtocol,
        healthKitService: HealthKitServiceProtocol,
        editing: BodyMeasurement? = nil,
        onSaved: @escaping @MainActor () -> Void
    ) {
        _viewModel = State(initialValue: NewMeasurementViewModel(
            repository: repository,
            profileRepository: profileRepository,
            healthKitService: healthKitService,
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
                        Task {
                            await viewModel.save()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.canSave || viewModel.isSaving)
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
        onSaved: {}
    )
}

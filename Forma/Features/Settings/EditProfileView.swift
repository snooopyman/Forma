//
//  EditProfileView.swift
//  Forma
//
//  Created by Armando Cáceres on 27/4/26.
//

import SwiftUI

struct EditProfileView: View {

    // MARK: - Private Properties

    @State private var viewModel: EditProfileViewModel

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Initializers

    init(profile: UserProfile, repository: UserProfileRepositoryProtocol) {
        _viewModel = State(initialValue: EditProfileViewModel(
            profile: profile,
            repository: repository
        ))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                personalSection
                trainingSection
                unitsSection

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.error)
                    }
                }
            }
            .navigationTitle(String(localized: "Edit profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        Task { await viewModel.save() }
                    }
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
            .disabled(viewModel.isSaving)
            .onChange(of: viewModel.saveSucceeded) { _, succeeded in
                if succeeded { dismiss() }
            }
        }
    }

    // MARK: - Private Views

    private var personalSection: some View {
        Section(String(localized: "Personal")) {
            TextField(String(localized: "Name"), text: $viewModel.name)
                .textContentType(.givenName)

            DatePicker(
                String(localized: "Date of birth"),
                selection: $viewModel.birthDate,
                in: viewModel.birthDateRange,
                displayedComponents: .date
            )

            Stepper(value: $viewModel.heightCm, in: 140...220, step: 1) {
                HStack {
                    Text(String(localized: "Height"))
                    Spacer()
                    Text(verbatim: "\(Int(viewModel.heightCm)) cm")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            Picker(String(localized: "Biological sex"), selection: $viewModel.biologicalSex) {
                ForEach(BiologicalSex.allCases, id: \.self) { sex in
                    Text(sex.localizedName).tag(sex)
                }
            }
        }
    }

    private var trainingSection: some View {
        Section(String(localized: "Training")) {
            Picker(String(localized: "Activity level"), selection: $viewModel.activityLevel) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text(level.localizedName)
                        Text(level.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(level)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private var unitsSection: some View {
        Section(String(localized: "Units")) {
            Picker(String(localized: "Weight unit"), selection: $viewModel.weightUnit) {
                ForEach(WeightUnit.allCases, id: \.self) { unit in
                    Text(unit.localizedName).tag(unit)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    EditProfileView(
        profile: UserProfile(
            name: "Armando",
            birthDate: Calendar.current.date(byAdding: .year, value: -28, to: .now) ?? .now,
            heightCm: 178,
            biologicalSex: .male
        ),
        repository: MockUserProfileRepository()
    )
}

//
//  CreateWorkoutDayView.swift
//  Forma
//
//  Created by Armando Cáceres on 31/3/26.
//

import SwiftUI
import SwiftData

struct CreateWorkoutDayView: View {

    // MARK: - Private Properties

    private let viewModel: MesocycleDetailViewModel

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - States

    @State private var name = ""
    @State private var isRestDay = false
    @State private var weekday: Weekday? = nil
    @State private var isSaving = false
    @State private var errorMessage: String?

    // MARK: - Initializers

    init(viewModel: MesocycleDetailViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Day name"), text: $name)
                    Toggle(String(localized: "Rest day"), isOn: $isRestDay.animation())
                }
                if !isRestDay && viewModel.mesocycle.useFixedDays {
                    Section {
                        Picker(String(localized: "Weekday"), selection: $weekday) {
                            Text(String(localized: "Not fixed")).tag(Optional<Weekday>.none)
                            ForEach(Weekday.allCases, id: \.self) { day in
                                Text(day.localizedName).tag(Optional(day))
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "New day"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Save")) {
                        Task { await save() }
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .alert(
                String(localized: "Error"),
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                if let msg = errorMessage { Text(msg) }
            }
        }
    }

    // MARK: - Private Functions

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        await viewModel.addWorkoutDay(
            name: name.trimmingCharacters(in: .whitespaces),
            isRestDay: isRestDay,
            weekday: weekday
        )
        if viewModel.errorMessage != nil {
            errorMessage = viewModel.errorMessage
            viewModel.errorMessage = nil
        } else {
            dismiss()
        }
    }
}

//
//  CreateMesocycleView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct CreateMesocycleView: View {

    // MARK: - Environment

    @Environment(AppContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let onSaved: () -> Void

    // MARK: - States

    @State private var name = ""
    @State private var durationWeeks = 6
    @State private var useFixedDays = true
    @State private var startDate = Date.now
    @State private var isSaving = false
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Name"), text: $name)
                }
                Section {
                    Stepper(value: $durationWeeks, in: 2...24) {
                        HStack {
                            Text(String(localized: "Duration"))
                            Spacer()
                            Text("\(durationWeeks) weeks")
                                .foregroundStyle(.textSecondary)
                        }
                    }
                    DatePicker(String(localized: "Start date"), selection: $startDate, displayedComponents: .date)
                    Toggle(String(localized: "Fixed days"), isOn: $useFixedDays)
                }
            }
            .navigationTitle(String(localized: "New mesocycle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
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
        let mesocycle = Mesocycle(
            name: name.trimmingCharacters(in: .whitespaces),
            startDate: startDate,
            durationWeeks: durationWeeks,
            useFixedDays: useFixedDays
        )
        do {
            try await container.mesocycleRepository.save(mesocycle)
            onSaved()
            dismiss()
        } catch {
            errorMessage = String(localized: "Something went wrong")
        }
    }
}

#Preview(traits: .previewContainer(.empty)) {
    CreateMesocycleView {}
}

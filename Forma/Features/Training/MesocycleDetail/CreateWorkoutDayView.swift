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

    private let mesocycle: Mesocycle
    private let mesocycleRepository: MesocycleRepositoryProtocol

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - States

    @State private var name = ""
    @State private var isRestDay = false
    @State private var weekday: Weekday? = nil
    @State private var isSaving = false
    @State private var errorMessage: String?

    // MARK: - Initializers

    init(mesocycle: Mesocycle, mesocycleRepository: MesocycleRepositoryProtocol) {
        self.mesocycle = mesocycle
        self.mesocycleRepository = mesocycleRepository
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Day name"), text: $name)
                    Toggle(String(localized: "Rest day"), isOn: $isRestDay.animation())
                }
                if !isRestDay && mesocycle.useFixedDays {
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
            .navigationTitle(String(localized: "New workout day"))
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
        let day = WorkoutDay(
            name: name.trimmingCharacters(in: .whitespaces),
            order: mesocycle.workoutDays.count,
            weekday: isRestDay ? nil : weekday,
            isRestDay: isRestDay
        )
        do {
            try await mesocycleRepository.addWorkoutDay(day, to: mesocycle)
            dismiss()
        } catch {
            errorMessage = String(localized: "Something went wrong")
        }
    }
}

//
//  AddPlannedExerciseView.swift
//  Forma
//
//  Created by Armando Cáceres on 31/3/26.
//

import SwiftUI

struct AddPlannedExerciseView: View {

    // MARK: - Private Properties

    private let workoutDay: WorkoutDay
    private let mesocycleRepository: MesocycleRepositoryProtocol

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - States

    @State private var exerciseName = ""
    @State private var muscle: MuscleGroup = .chest
    @State private var sets = 3
    @State private var repsMin = 8
    @State private var repsMax = 12
    @State private var rir = 2
    @State private var restSeconds = 120
    @State private var isSaving = false
    @State private var errorMessage: String?

    // MARK: - Initializers

    init(workoutDay: WorkoutDay, mesocycleRepository: MesocycleRepositoryProtocol) {
        self.workoutDay = workoutDay
        self.mesocycleRepository = mesocycleRepository
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Exercise name"), text: $exerciseName)
                    Picker(String(localized: "Muscle group"), selection: $muscle) {
                        ForEach(MuscleGroup.allCases, id: \.self) { m in
                            Text(m.localizedName).tag(m)
                        }
                    }
                }
                Section(String(localized: "Sets & reps")) {
                    Stepper(value: $sets, in: 1...10) {
                        HStack {
                            Text(String(localized: "Sets"))
                            Spacer()
                            Text(verbatim: "\(sets)")
                                .foregroundStyle(.textSecondary)
                        }
                    }
                    Stepper(value: $repsMin, in: 1...30) {
                        HStack {
                            Text(String(localized: "Min reps"))
                            Spacer()
                            Text(verbatim: "\(repsMin)")
                                .foregroundStyle(.textSecondary)
                        }
                    }
                    Stepper(value: $repsMax, in: repsMin...30) {
                        HStack {
                            Text(String(localized: "Max reps"))
                            Spacer()
                            Text(verbatim: "\(repsMax)")
                                .foregroundStyle(.textSecondary)
                        }
                    }
                }
                Section(String(localized: "Intensity")) {
                    Stepper(value: $rir, in: 0...5) {
                        HStack {
                            Text(verbatim: "RIR")
                            Spacer()
                            Text(verbatim: "\(rir)")
                                .foregroundStyle(.textSecondary)
                        }
                    }
                    Picker(String(localized: "Rest"), selection: $restSeconds) {
                        Text(verbatim: "60s").tag(60)
                        Text(verbatim: "90s").tag(90)
                        Text(verbatim: "2 min").tag(120)
                        Text(verbatim: "3 min").tag(180)
                        Text(verbatim: "4 min").tag(240)
                    }
                }
            }
            .navigationTitle(String(localized: "Add exercise"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Add")) {
                        Task { await save() }
                    }
                    .fontWeight(.semibold)
                    .disabled(exerciseName.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
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
        let exercise = Exercise(
            name: exerciseName.trimmingCharacters(in: .whitespaces),
            primaryMuscle: muscle,
            isCustom: true
        )
        let planned = PlannedExercise(
            order: workoutDay.plannedExercises.count,
            sets: sets,
            repsMin: repsMin,
            repsMax: repsMax,
            rirTarget: rir,
            restSeconds: restSeconds
        )
        do {
            try await mesocycleRepository.addPlannedExercise(planned, exercise: exercise, to: workoutDay)
            dismiss()
        } catch {
            errorMessage = String(localized: "Something went wrong")
        }
    }
}

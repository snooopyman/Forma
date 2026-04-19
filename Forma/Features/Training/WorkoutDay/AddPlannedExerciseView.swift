//
//  AddPlannedExerciseView.swift
//  Forma
//
//  Created by Armando Cáceres on 31/3/26.
//

import SwiftUI

struct AddPlannedExerciseView: View {

    // MARK: - Private Properties

    private let workoutDay: WorkoutDay?
    private let editingExercise: PlannedExercise?
    private let mesocycleRepository: MesocycleRepositoryProtocol

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - States

    @State private var exerciseName: String
    @State private var muscle: MuscleGroup
    @State private var sets: Int
    @State private var repsMin: Int
    @State private var repsMax: Int
    @State private var rir: Int
    @State private var restSeconds: Int
    @State private var isSaving = false
    @State private var errorMessage: String?

    // MARK: - Computed Properties

    private var isEditMode: Bool { editingExercise != nil }

    // MARK: - Initializers

    init(workoutDay: WorkoutDay, mesocycleRepository: MesocycleRepositoryProtocol) {
        self.workoutDay = workoutDay
        self.editingExercise = nil
        self.mesocycleRepository = mesocycleRepository
        _exerciseName = State(initialValue: "")
        _muscle = State(initialValue: .chest)
        _sets = State(initialValue: 3)
        _repsMin = State(initialValue: 8)
        _repsMax = State(initialValue: 12)
        _rir = State(initialValue: 2)
        _restSeconds = State(initialValue: 120)
    }

    init(editing planned: PlannedExercise, mesocycleRepository: MesocycleRepositoryProtocol) {
        self.workoutDay = nil
        self.editingExercise = planned
        self.mesocycleRepository = mesocycleRepository
        _exerciseName = State(initialValue: planned.exercise?.name ?? "")
        _muscle = State(initialValue: planned.exercise?.primaryMuscle ?? .chest)
        _sets = State(initialValue: planned.sets)
        _repsMin = State(initialValue: planned.repsMin)
        _repsMax = State(initialValue: planned.repsMax)
        _rir = State(initialValue: planned.rirTarget)
        _restSeconds = State(initialValue: planned.restSeconds)
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
            .navigationTitle(isEditMode ? String(localized: "Edit exercise") : String(localized: "Add exercise"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditMode ? String(localized: "Save") : String(localized: "Add")) {
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
        do {
            if let planned = editingExercise {
                try await mesocycleRepository.updatePlannedExercise(
                    planned,
                    name: exerciseName.trimmingCharacters(in: .whitespaces),
                    muscle: muscle,
                    sets: sets,
                    repsMin: repsMin,
                    repsMax: repsMax,
                    rir: rir,
                    restSeconds: restSeconds
                )
            } else if let day = workoutDay {
                let exercise = Exercise(
                    name: exerciseName.trimmingCharacters(in: .whitespaces),
                    primaryMuscle: muscle,
                    isCustom: true
                )
                let planned = PlannedExercise(
                    order: day.plannedExercises.count,
                    sets: sets,
                    repsMin: repsMin,
                    repsMax: repsMax,
                    rirTarget: rir,
                    restSeconds: restSeconds
                )
                try await mesocycleRepository.addPlannedExercise(planned, exercise: exercise, to: day)
            }
            dismiss()
        } catch {
            errorMessage = String(localized: "Something went wrong")
        }
    }
}

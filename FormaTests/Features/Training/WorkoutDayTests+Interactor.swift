//
//  WorkoutDayTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
@testable import Forma

extension WorkoutDayTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: WorkoutDayInteractor

        // MARK: - Spies

        let spyMesocycleRepository: SpyMesocycleRepository
        let spySessionRepository: SpyWorkoutSessionRepository
        let spySessionService: SpyWorkoutSessionService

        // MARK: - Initializers

        init() {
            spyMesocycleRepository = SpyMesocycleRepository()
            spySessionRepository = SpyWorkoutSessionRepository()
            spySessionService = SpyWorkoutSessionService()
            sut = WorkoutDayInteractor(
                mesocycleRepository: spyMesocycleRepository,
                sessionRepository: spySessionRepository,
                sessionService: spySessionService
            )
        }

        @Test("fetchInProgressSession delegates to session repository")
        func fetchInProgressSessionTracked() async throws {
            _ = try await sut.fetchInProgressSession()
            #expect(spySessionRepository.fetchInProgressWasCalled == true)
        }

        @Test("deletePlannedExercise delegates to mesocycle repository")
        func deletePlannedExerciseTracked() async throws {
            let planned = PlannedExercise(order: 0)
            try await sut.deletePlannedExercise(planned)
            #expect(spyMesocycleRepository.deletePlannedExerciseWasCalled == true)
            #expect(spyMesocycleRepository.lastDeletedPlannedExercise?.id == planned.id)
        }

        @Test("startSession delegates to session service")
        func startSessionTracked() async throws {
            let day = WorkoutDay(name: "Push", order: 0)
            let mesocycle = Mesocycle(name: "Block 1")
            let session = WorkoutSession()
            spySessionService.stubbedStartedSession = session
            let result = try await sut.startSession(for: day, in: mesocycle)
            #expect(spySessionService.startSessionWasCalled == true)
            #expect(result.id == session.id)
        }

        @Test("addPlannedExercise delegates to mesocycle repository")
        func addPlannedExerciseTracked() async throws {
            let day = WorkoutDay(name: "Push", order: 0)
            let exercise = Exercise(name: "Bench Press", primaryMuscle: .chest)
            let planned = PlannedExercise(order: 0)
            try await sut.addPlannedExercise(planned, exercise: exercise, to: day)
            #expect(spyMesocycleRepository.addPlannedExerciseWasCalled == true)
            #expect(spyMesocycleRepository.lastAddedPlannedExercise?.id == planned.id)
        }

        @Test("updatePlannedExercise delegates to mesocycle repository")
        func updatePlannedExerciseTracked() async throws {
            let planned = PlannedExercise(order: 0)
            try await sut.updatePlannedExercise(planned, name: "Incline Press", muscle: .chest, equipment: .barbell, sets: 3, repsMin: 8, repsMax: 12, rir: 1, restSeconds: 90)
            #expect(spyMesocycleRepository.updatePlannedExerciseWasCalled == true)
            #expect(spyMesocycleRepository.lastUpdatedPlannedExercise?.id == planned.id)
        }
    }
}

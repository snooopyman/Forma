//
//  MesocycleDetailTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
@testable import Forma

extension MesocycleDetailTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: MesocycleDetailInteractor

        // MARK: - Spies

        let spyMesocycleRepository: SpyMesocycleRepository
        let spySessionRepository: SpyWorkoutSessionRepository

        // MARK: - Initializers

        init() {
            spyMesocycleRepository = SpyMesocycleRepository()
            spySessionRepository = SpyWorkoutSessionRepository()
            sut = MesocycleDetailInteractor(mesocycleRepository: spyMesocycleRepository, sessionRepository: spySessionRepository)
        }

        @Test("fetchSessions delegates to session repository")
        func fetchSessionsTracked() async throws {
            let mesocycle = Mesocycle(name: "Block 1")
            _ = try await sut.fetchSessions(for: mesocycle)
            #expect(spySessionRepository.fetchAllWasCalled == true)
        }

        @Test("fetchSessions propagates error")
        func fetchSessionsPropagatesError() async {
            spySessionRepository.shouldThrowError = true
            spySessionRepository.errorToThrow = TrainingError.loadFailed
            let mesocycle = Mesocycle(name: "Block 1")
            await #expect(throws: TrainingError.self) {
                _ = try await sut.fetchSessions(for: mesocycle)
            }
        }

        @Test("fetchInProgressSession delegates to session repository")
        func fetchInProgressSessionTracked() async throws {
            _ = try await sut.fetchInProgressSession()
            #expect(spySessionRepository.fetchInProgressWasCalled == true)
        }

        @Test("activate delegates to mesocycle repository")
        func activateTracked() async throws {
            let mesocycle = Mesocycle(name: "Block 1")
            try await sut.activate(mesocycle)
            #expect(spyMesocycleRepository.setActiveWasCalled == true)
            #expect(spyMesocycleRepository.lastActivatedMesocycle?.id == mesocycle.id)
        }

        @Test("pause delegates to mesocycle repository")
        func pauseTracked() async throws {
            let mesocycle = Mesocycle(name: "Block 1")
            try await sut.pause(mesocycle)
            #expect(spyMesocycleRepository.pauseWasCalled == true)
        }

        @Test("resume delegates to mesocycle repository")
        func resumeTracked() async throws {
            let mesocycle = Mesocycle(name: "Block 1")
            try await sut.resume(mesocycle)
            #expect(spyMesocycleRepository.resumeWasCalled == true)
        }

        @Test("addWorkoutDay delegates to mesocycle repository")
        func addWorkoutDayTracked() async throws {
            let mesocycle = Mesocycle(name: "Block 1")
            let day = WorkoutDay(name: "Push", order: 0)
            try await sut.addWorkoutDay(day, to: mesocycle)
            #expect(spyMesocycleRepository.addWorkoutDayWasCalled == true)
            #expect(spyMesocycleRepository.lastAddedWorkoutDay?.id == day.id)
        }
    }
}

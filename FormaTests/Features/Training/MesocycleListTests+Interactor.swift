//
//  MesocycleListTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
@testable import Forma

extension MesocycleListTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        let sut: MesocycleListInteractor
        let spy: SpyMesocycleRepository

        init() {
            spy = SpyMesocycleRepository()
            sut = MesocycleListInteractor(repository: spy)
        }

        @Test("fetchMesocycles delegates to repository")
        func fetchMesocyclesCallsRepo() async throws {
            spy.stubbedMesocycles = Self.sampleMesocycles
            let result = try await sut.fetchMesocycles()
            #expect(spy.fetchAllWasCalled == true)
            #expect(result.count == Self.sampleMesocycles.count)
        }

        @Test("fetchMesocycles propagates repository error")
        func fetchMesocyclesPropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.loadFailed
            await #expect(throws: TrainingError.self) {
                _ = try await sut.fetchMesocycles()
            }
        }

        @Test("deleteMesocycle passes correct item to repository")
        func deleteMesocycleCallsRepo() async throws {
            let mesocycle = Mesocycle(name: "Test", durationWeeks: 4)
            try await sut.deleteMesocycle(mesocycle)
            #expect(spy.deleteWasCalled == true)
            #expect(spy.lastDeletedMesocycle?.id == mesocycle.id)
        }

        @Test("deleteMesocycle propagates repository error")
        func deleteMesocyclePropagatesError() async {
            let mesocycle = Mesocycle(name: "Test", durationWeeks: 4)
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.deleteFailed
            await #expect(throws: TrainingError.self) {
                try await sut.deleteMesocycle(mesocycle)
            }
        }

        @Test("setActiveMesocycle passes correct item to repository")
        func setActiveMesocycleCallsRepo() async throws {
            let mesocycle = Mesocycle(name: "Active", durationWeeks: 4)
            try await sut.setActiveMesocycle(mesocycle)
            #expect(spy.setActiveWasCalled == true)
            #expect(spy.lastActivatedMesocycle?.id == mesocycle.id)
        }
    }
}

// MARK: - Test Data

private extension MesocycleListTests.InteractorTests {
    static var sampleMesocycles: [Mesocycle] {
        [Mesocycle(name: "Block A", durationWeeks: 4), Mesocycle(name: "Block B", durationWeeks: 6)]
    }
}

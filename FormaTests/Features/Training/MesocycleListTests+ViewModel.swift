//
//  MesocycleListTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
@testable import Forma

extension MesocycleListTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: MesocycleListViewModel
        let spy: SpyMesocycleListInteractor

        init() {
            spy = SpyMesocycleListInteractor()
            sut = MesocycleListViewModel(interactor: spy)
        }

        @Test("load() calls fetchMesocycles and populates mesocycles")
        func loadSuccess() async {
            spy.stubbedMesocycles = Self.sampleMesocycles
            await sut.load()
            #expect(spy.fetchMesocyclesWasCalled == true)
            #expect(sut.mesocycles.count == Self.sampleMesocycles.count)
            #expect(sut.isLoading == false)
            #expect(sut.errorMessage == nil)
        }

        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == TrainingError.loadFailed.errorDescription)
            #expect(sut.mesocycles.isEmpty)
            #expect(sut.isLoading == false)
        }

        @Test("load() guard prevents concurrent calls")
        func loadGuard() async {
            async let first: Void = sut.load()
            async let second: Void = sut.load()
            _ = await (first, second)
            #expect(spy.fetchMesocyclesWasCalled == true)
        }

        @Test("delete() calls interactor and removes from mesocycles")
        func deleteSuccess() async throws {
            spy.stubbedMesocycles = Self.sampleMesocycles
            await sut.load()
            let target = try #require(sut.mesocycles.first)
            await sut.delete(target)
            #expect(spy.deleteMesocycleWasCalled == true)
            #expect(sut.mesocycles.contains { $0.id == target.id } == false)
        }

        @Test("delete() sets errorMessage on failure")
        func deleteFailure() async throws {
            spy.stubbedMesocycles = Self.sampleMesocycles
            await sut.load()
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.deleteFailed
            let target = try #require(sut.mesocycles.first)
            await sut.delete(target)
            #expect(sut.errorMessage == TrainingError.deleteFailed.errorDescription)
        }

        @Test("setActive() calls interactor and reloads")
        func setActiveSuccess() async throws {
            spy.stubbedMesocycles = Self.sampleMesocycles
            await sut.load()
            let target = try #require(sut.mesocycles.first)
            await sut.setActive(target)
            #expect(spy.setActiveMesocycleWasCalled == true)
            #expect(spy.fetchMesocyclesWasCalled == true)
        }

        @Test(
            "handleError maps domain errors correctly",
            arguments: [
                ErrorCase(error: TrainingError.loadFailed,      expected: TrainingError.loadFailed.errorDescription ?? ""),
                ErrorCase(error: TrainingError.deleteFailed,    expected: TrainingError.deleteFailed.errorDescription ?? ""),
                ErrorCase(error: TrainingError.setActiveFailed, expected: TrainingError.setActiveFailed.errorDescription ?? "")
            ]
        )
        private func handleErrorTypes(errorCase: ErrorCase) async {
            spy.shouldThrowError = true
            spy.errorToThrow = errorCase.error
            await sut.load()
            #expect(sut.errorMessage == errorCase.expected)
        }
    }
}

// MARK: - Test Data

private extension MesocycleListTests.ViewModelTests {
    static let sampleMesocycles: [Mesocycle] = [
        Mesocycle(name: "Strength Block", durationWeeks: 4),
        Mesocycle(name: "Hypertrophy", durationWeeks: 6)
    ]

    struct ErrorCase: CustomTestStringConvertible {
        let error: TrainingError
        let expected: String
        var testDescription: String { "\(error) → \(expected)" }
    }
}

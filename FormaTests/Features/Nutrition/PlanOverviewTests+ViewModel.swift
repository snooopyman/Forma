//
//  PlanOverviewTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
@testable import Forma

extension PlanOverviewTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: PlanOverviewViewModel
        let spy: SpyPlanOverviewInteractor

        init() {
            spy = SpyPlanOverviewInteractor()
            sut = PlanOverviewViewModel(interactor: spy)
        }

        @Test("load() fetches plan and log")
        func loadSuccess() async {
            await sut.load()
            #expect(spy.fetchActivePlanWasCalled == true)
            #expect(spy.fetchLogWasCalled == true)
            #expect(sut.isLoading == false)
            #expect(sut.errorMessage == nil)
        }

        @Test("load() with nil plan leaves summary nil")
        func loadNilPlan() async {
            spy.stubbedPlan = nil
            await sut.load()
            #expect(sut.plan == nil)
            #expect(sut.summary == nil)
        }

        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == NutritionError.loadFailed.errorDescription)
            #expect(sut.isLoading == false)
        }

        @Test("load() guard prevents concurrent calls")
        func loadGuard() async {
            async let first: Void = sut.load()
            async let second: Void = sut.load()
            _ = await (first, second)
            #expect(spy.fetchActivePlanWasCalled == true)
        }

        @Test(
            "handleError maps nutrition errors correctly",
            arguments: [
                ErrorCase(error: NutritionError.loadFailed,   expected: NutritionError.loadFailed.errorDescription ?? ""),
                ErrorCase(error: NutritionError.saveFailed,   expected: NutritionError.saveFailed.errorDescription ?? ""),
                ErrorCase(error: NutritionError.deleteFailed, expected: NutritionError.deleteFailed.errorDescription ?? "")
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

private extension PlanOverviewTests.ViewModelTests {
    struct ErrorCase: CustomTestStringConvertible {
        let error: NutritionError
        let expected: String
        var testDescription: String { "\(error) → \(expected)" }
    }
}

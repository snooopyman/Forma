//
//  ProgressOverviewTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
import Foundation
@testable import Forma

extension ProgressOverviewTests {
    
    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {
        
        let sut: ProgressOverviewViewModel
        let spy: SpyProgressInteractor
        
        init() {
            spy = SpyProgressInteractor()
            sut = ProgressOverviewViewModel(interactor: spy)
        }
        
        @Test("load() calls fetchMeasurements and populates measurements")
        func loadSuccess() async {
            spy.stubbedMeasurements = Self.sampleMeasurements
            await sut.load()
            #expect(spy.fetchMeasurementsWasCalled == true)
            #expect(sut.measurements.count == Self.sampleMeasurements.count)
            #expect(sut.isLoading == false)
            #expect(sut.errorMessage == nil)
        }
        
        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = ProgressError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == ProgressError.loadFailed.errorDescription)
            #expect(sut.measurements.isEmpty)
            #expect(sut.isLoading == false)
        }
        
        @Test("latest returns first measurement")
        func latest() async throws {
            spy.stubbedMeasurements = Self.sampleMeasurements
            await sut.load()
            let first = try #require(sut.measurements.first)
            #expect(sut.latest?.id == first.id)
        }
        
        @Test("weightDelta computes difference between first two measurements")
        func weightDelta() async {
            spy.stubbedMeasurements = Self.sampleMeasurements
            await sut.load()
            let expected = sut.measurements[0].weightKg - sut.measurements[1].weightKg
            #expect(sut.weightDelta == expected)
        }
        
        @Test("delete() calls interactor and reloads")
        func deleteSuccess() async throws {
            spy.stubbedMeasurements = Self.sampleMeasurements
            await sut.load()
            let target = try #require(sut.measurements.first)
            await sut.delete(target)
            #expect(spy.deleteMeasurementWasCalled == true)
            #expect(spy.lastDeletedMeasurement?.id == target.id)
        }
        
        @Test("delete() sets errorMessage on failure")
        func deleteFailure() async throws {
            spy.stubbedMeasurements = Self.sampleMeasurements
            await sut.load()
            spy.shouldThrowError = true
            spy.errorToThrow = ProgressError.deleteFailed
            let target = try #require(sut.measurements.first)
            await sut.delete(target)
            #expect(sut.errorMessage == ProgressError.deleteFailed.errorDescription)
        }
        
        @Test(
            "handleError maps progress errors correctly",
            arguments: [
                ErrorCase(error: ProgressError.loadFailed,   expected: ProgressError.loadFailed.errorDescription ?? ""),
                ErrorCase(error: ProgressError.saveFailed,   expected: ProgressError.saveFailed.errorDescription ?? ""),
                ErrorCase(error: ProgressError.deleteFailed, expected: ProgressError.deleteFailed.errorDescription ?? "")
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

private extension ProgressOverviewTests.ViewModelTests {
    static let sampleMeasurements: [BodyMeasurement] = [
        BodyMeasurement(date: .now, weightKg: 80.0, heightCm: 178, biologicalSex: .male),
        BodyMeasurement(
            date: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now) ?? .now,
            weightKg: 81.5,
            heightCm: 178,
            biologicalSex: .male
        )
    ]
    
    struct ErrorCase: CustomTestStringConvertible {
        let error: ProgressError
        let expected: String
        var testDescription: String { "\(error) → \(expected)" }
    }
}

//
//  ProgressOverviewTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 29/6/26.
//

import Testing
@testable import Forma

extension ProgressOverviewTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        let sut: ProgressInteractor
        let spy: SpyBodyMeasurementRepository

        init() {
            spy = SpyBodyMeasurementRepository()
            sut = ProgressInteractor(repository: spy)
        }

        @Test("fetchMeasurements delegates to repository")
        func fetchMeasurementsCallsRepo() async throws {
            spy.stubbedMeasurements = Self.sampleMeasurements
            let result = try await sut.fetchMeasurements()
            #expect(spy.fetchAllWasCalled == true)
            #expect(result.count == Self.sampleMeasurements.count)
        }

        @Test("fetchMeasurements propagates repository error")
        func fetchMeasurementsPropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = ProgressError.loadFailed
            await #expect(throws: ProgressError.self) {
                _ = try await sut.fetchMeasurements()
            }
        }

        @Test("deleteMeasurement passes correct item to repository")
        func deleteMeasurementCallsRepo() async throws {
            let measurement = BodyMeasurement(weightKg: 80, heightCm: 178, biologicalSex: .male)
            try await sut.deleteMeasurement(measurement)
            #expect(spy.deleteWasCalled == true)
            #expect(spy.lastDeletedMeasurement?.id == measurement.id)
        }

        @Test("deleteMeasurement propagates repository error")
        func deleteMeasurementPropagatesError() async {
            let measurement = BodyMeasurement(weightKg: 80, heightCm: 178, biologicalSex: .male)
            spy.shouldThrowError = true
            spy.errorToThrow = ProgressError.deleteFailed
            await #expect(throws: ProgressError.self) {
                try await sut.deleteMeasurement(measurement)
            }
        }
    }
}

// MARK: - Test Data

private extension ProgressOverviewTests.InteractorTests {
    static var sampleMeasurements: [BodyMeasurement] {
        [
            BodyMeasurement(weightKg: 80.0, heightCm: 178, biologicalSex: .male),
            BodyMeasurement(weightKg: 81.5, heightCm: 178, biologicalSex: .male)
        ]
    }
}

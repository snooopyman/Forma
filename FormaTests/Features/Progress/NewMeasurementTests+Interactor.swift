//
//  NewMeasurementTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension NewMeasurementTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: NewMeasurementInteractor

        // MARK: - Spies

        let spyMeasurementRepository: SpyBodyMeasurementRepository
        let spyProfileRepository: SpyUserProfileRepository
        let spyHealthKitService: SpyHealthKitService

        // MARK: - Initializers

        init() {
            spyMeasurementRepository = SpyBodyMeasurementRepository()
            spyProfileRepository = SpyUserProfileRepository()
            spyHealthKitService = SpyHealthKitService()
            sut = NewMeasurementInteractor(
                measurementRepository: spyMeasurementRepository,
                profileRepository: spyProfileRepository,
                healthKitService: spyHealthKitService
            )
        }

        @Test("fetchProfile delegates to profile repository")
        func fetchProfileTracked() async throws {
            _ = try await sut.fetchProfile()
            #expect(spyProfileRepository.fetchWasCalled == true)
        }

        @Test("fetchLatestWeight delegates to HealthKit service")
        func fetchLatestWeightTracked() async {
            spyHealthKitService.stubbedLatestWeight = 75.0
            let weight = await sut.fetchLatestWeight()
            #expect(spyHealthKitService.fetchLatestWeightWasCalled == true)
            #expect(weight == 75.0)
        }

        @Test("saveMeasurement delegates to measurement repository")
        func saveMeasurementTracked() async throws {
            let measurement = BodyMeasurement(weightKg: 70, heightCm: 170, biologicalSex: .male)
            try await sut.saveMeasurement(measurement)
            #expect(spyMeasurementRepository.saveWasCalled == true)
            #expect(spyMeasurementRepository.lastSavedMeasurement?.id == measurement.id)
        }

        @Test("saveMeasurement propagates error")
        func saveMeasurementPropagatesError() async {
            spyMeasurementRepository.shouldThrowError = true
            spyMeasurementRepository.errorToThrow = ProgressError.saveFailed
            let measurement = BodyMeasurement(weightKg: 70, heightCm: 170, biologicalSex: .male)
            await #expect(throws: ProgressError.self) {
                try await sut.saveMeasurement(measurement)
            }
        }

        @Test("updateMeasurement delegates to measurement repository")
        func updateMeasurementTracked() async throws {
            let measurement = BodyMeasurement(weightKg: 70, heightCm: 170, biologicalSex: .male)
            try await sut.updateMeasurement(measurement)
            #expect(spyMeasurementRepository.updateWasCalled == true)
            #expect(spyMeasurementRepository.lastUpdatedMeasurement?.id == measurement.id)
        }

        @Test("writeWeight delegates to HealthKit service")
        func writeWeightTracked() async {
            await sut.writeWeight(75, date: .now)
            #expect(spyHealthKitService.writeWeightWasCalled == true)
            #expect(spyHealthKitService.lastWrittenWeight == 75)
        }
    }
}

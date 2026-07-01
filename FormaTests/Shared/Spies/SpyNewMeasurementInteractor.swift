//
//  SpyNewMeasurementInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyNewMeasurementInteractor: NewMeasurementInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var fetchProfileWasCalled = false
    private(set) var fetchLatestWeightWasCalled = false
    private(set) var saveMeasurementWasCalled = false
    private(set) var updateMeasurementWasCalled = false
    private(set) var writeWeightWasCalled = false
    private(set) var lastSavedMeasurement: BodyMeasurement?
    private(set) var lastUpdatedMeasurement: BodyMeasurement?
    private(set) var lastWrittenWeight: Double?

    // MARK: - Stub Data

    var stubbedProfile: UserProfile?
    var stubbedLatestWeight: Double?
    var shouldThrowError = false
    var errorToThrow: Error = ProgressError.saveFailed

    // MARK: - Functions

    func reset() {
        fetchProfileWasCalled = false
        fetchLatestWeightWasCalled = false
        saveMeasurementWasCalled = false
        updateMeasurementWasCalled = false
        writeWeightWasCalled = false
        lastSavedMeasurement = nil
        lastUpdatedMeasurement = nil
        lastWrittenWeight = nil
    }

    func fetchProfile() async throws -> UserProfile? {
        fetchProfileWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedProfile
    }

    func fetchLatestWeight() async -> Double? {
        fetchLatestWeightWasCalled = true
        return stubbedLatestWeight
    }

    func saveMeasurement(_ measurement: BodyMeasurement) async throws {
        saveMeasurementWasCalled = true
        lastSavedMeasurement = measurement
        if shouldThrowError { throw errorToThrow }
    }

    func updateMeasurement(_ measurement: BodyMeasurement) async throws {
        updateMeasurementWasCalled = true
        lastUpdatedMeasurement = measurement
        if shouldThrowError { throw errorToThrow }
    }

    func writeWeight(_ kg: Double, date: Date) async {
        writeWeightWasCalled = true
        lastWrittenWeight = kg
    }
}

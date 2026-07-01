//
//  MockNewMeasurementInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockNewMeasurementInteractor: NewMeasurementInteractorProtocol {

    // MARK: - Stub Data

    nonisolated(unsafe) var stubbedProfile: UserProfile?
    nonisolated(unsafe) var stubbedLatestWeight: Double?
    nonisolated(unsafe) var shouldThrowOnSave = false

    // MARK: - Functions

    func fetchProfile() async throws -> UserProfile? {
        stubbedProfile
    }

    func fetchLatestWeight() async -> Double? {
        stubbedLatestWeight
    }

    func saveMeasurement(_ measurement: BodyMeasurement) async throws {
        if shouldThrowOnSave { throw ProgressError.saveFailed }
    }

    func updateMeasurement(_ measurement: BodyMeasurement) async throws {
        if shouldThrowOnSave { throw ProgressError.saveFailed }
    }

    func writeWeight(_ kg: Double, date: Date) async { }
}

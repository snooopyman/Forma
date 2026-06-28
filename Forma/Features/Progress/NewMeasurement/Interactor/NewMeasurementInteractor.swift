//
//  NewMeasurementInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class NewMeasurementInteractor: NewMeasurementInteractorProtocol {

    // MARK: - Private Properties

    private let measurementRepository: BodyMeasurementRepositoryProtocol
    private let profileRepository: UserProfileRepositoryProtocol
    private let healthKitService: HealthKitServiceProtocol

    // MARK: - Initializers

    init(
        measurementRepository: BodyMeasurementRepositoryProtocol,
        profileRepository: UserProfileRepositoryProtocol,
        healthKitService: HealthKitServiceProtocol
    ) {
        self.measurementRepository = measurementRepository
        self.profileRepository = profileRepository
        self.healthKitService = healthKitService
    }

    // MARK: - Functions

    func fetchProfile() async throws -> UserProfile? {
        try await profileRepository.fetch()
    }

    func fetchLatestWeight() async -> Double? {
        await healthKitService.fetchLatestWeight()
    }

    func saveMeasurement(_ measurement: BodyMeasurement) async throws {
        try await measurementRepository.save(measurement)
    }

    func updateMeasurement(_ measurement: BodyMeasurement) async throws {
        try await measurementRepository.update(measurement)
    }

    func writeWeight(_ kg: Double, date: Date) async {
        await healthKitService.writeWeight(kg, date: date)
    }
}

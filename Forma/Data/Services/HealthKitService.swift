//
//  HealthKitService.swift
//  Forma
//
//  Created by Armando Cáceres on 19/4/26.
//

import HealthKit
import OSLog

// MARK: - Protocol

protocol HealthKitServiceProtocol: Sendable {
    var isAvailable: Bool { get }
    func requestAuthorization() async throws
    func fetchTodaySteps() async -> Int
    func fetchTodayActiveCalories() async -> Double
    func fetchTodayExerciseMinutes() async -> Double
    func fetchLatestWeight() async -> Double?
}

// MARK: - Concrete

final class HealthKitService: HealthKitServiceProtocol, @unchecked Sendable {

    private let store = HKHealthStore()

    private let readTypes: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.appleExerciseTime),
        HKQuantityType(.bodyMass)
    ]

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async throws {
        guard isAvailable else { return }
        try await store.requestAuthorization(toShare: [], read: readTypes)
    }

    func fetchTodaySteps() async -> Int {
        Int(await fetchTodaySum(for: .stepCount, unit: .count()))
    }

    func fetchTodayActiveCalories() async -> Double {
        await fetchTodaySum(for: .activeEnergyBurned, unit: .kilocalorie())
    }

    func fetchTodayExerciseMinutes() async -> Double {
        await fetchTodaySum(for: .appleExerciseTime, unit: .minute())
    }

    func fetchLatestWeight() async -> Double? {
        guard isAvailable else { return nil }
        let type = HKQuantityType(.bodyMass)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: sample.quantity.doubleValue(for: .gramUnit(with: .kilo)))
            }
            store.execute(query)
        }
    }

    // MARK: - Private Functions

    private func fetchTodaySum(for identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double {
        guard isAvailable else { return 0 }
        let type = HKQuantityType(identifier)
        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            store.execute(query)
        }
    }
}

// MARK: - Mock

struct MockHealthKitService: HealthKitServiceProtocol {
    var isAvailable: Bool { true }
    func requestAuthorization() async throws {}
    func fetchTodaySteps() async -> Int { 7_432 }
    func fetchTodayActiveCalories() async -> Double { 320 }
    func fetchTodayExerciseMinutes() async -> Double { 45 }
    func fetchLatestWeight() async -> Double? { 78.5 }
}

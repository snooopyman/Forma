//
//  SpyHealthKitService.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
import HealthKit
@testable import Forma

final class SpyHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var requestAuthorizationWasCalled = false
    private(set) var fetchTodayStepsWasCalled = false
    private(set) var fetchTodayActiveCaloriesWasCalled = false
    private(set) var fetchTodayExerciseMinutesWasCalled = false
    private(set) var fetchLatestWeightWasCalled = false
    private(set) var writeWeightWasCalled = false
    private(set) var writeWorkoutWasCalled = false
    private(set) var lastWrittenWeight: Double?
    private(set) var lastWrittenWorkoutType: HKWorkoutActivityType?

    // MARK: - Stub Data

    var isAvailable = true
    var isAuthorized = false
    var stubbedSteps = 0
    var stubbedActiveCalories = 0.0
    var stubbedExerciseMinutes = 0.0
    var stubbedLatestWeight: Double?
    var shouldThrowError = false
    var errorToThrow: Error = SettingsError.loadFailed

    // MARK: - Functions

    func reset() {
        requestAuthorizationWasCalled = false
        fetchTodayStepsWasCalled = false
        fetchTodayActiveCaloriesWasCalled = false
        fetchTodayExerciseMinutesWasCalled = false
        fetchLatestWeightWasCalled = false
        writeWeightWasCalled = false
        writeWorkoutWasCalled = false
        lastWrittenWeight = nil
        lastWrittenWorkoutType = nil
    }

    func requestAuthorization() async throws {
        requestAuthorizationWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }

    func fetchTodaySteps() async -> Int {
        fetchTodayStepsWasCalled = true
        return stubbedSteps
    }

    func fetchTodayActiveCalories() async -> Double {
        fetchTodayActiveCaloriesWasCalled = true
        return stubbedActiveCalories
    }

    func fetchTodayExerciseMinutes() async -> Double {
        fetchTodayExerciseMinutesWasCalled = true
        return stubbedExerciseMinutes
    }

    func fetchLatestWeight() async -> Double? {
        fetchLatestWeightWasCalled = true
        return stubbedLatestWeight
    }

    func writeWeight(_ kg: Double, date: Date) async {
        writeWeightWasCalled = true
        lastWrittenWeight = kg
    }

    func writeWorkout(activityType: HKWorkoutActivityType, start: Date, end: Date) async {
        writeWorkoutWasCalled = true
        lastWrittenWorkoutType = activityType
    }
}

//
//  SpyMealDetailInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyMealDetailInteractor: MealDetailInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var fetchLogWasCalled = false
    private(set) var saveLogWasCalled = false
    private(set) var addMealLogWasCalled = false
    private(set) var removeMealLogWasCalled = false
    private(set) var saveWasCalled = false
    private(set) var insertMealOptionWasCalled = false
    private(set) var deleteMealOptionWasCalled = false
    private(set) var insertMealOptionItemWasCalled = false
    private(set) var deleteMealOptionItemWasCalled = false
    private(set) var lastAddedMealLog: MealLog?
    private(set) var lastRemovedMealLog: MealLog?
    private(set) var lastInsertedOption: MealOption?
    private(set) var lastDeletedOption: MealOption?
    private(set) var lastInsertedItem: MealOptionItem?
    private(set) var lastDeletedItem: MealOptionItem?

    // MARK: - Stub Data

    var stubbedLog: DailyNutritionLog?
    var shouldThrowError = false
    var errorToThrow: Error = NutritionError.saveFailed

    // MARK: - Functions

    func reset() {
        fetchLogWasCalled = false
        saveLogWasCalled = false
        addMealLogWasCalled = false
        removeMealLogWasCalled = false
        saveWasCalled = false
        insertMealOptionWasCalled = false
        deleteMealOptionWasCalled = false
        insertMealOptionItemWasCalled = false
        deleteMealOptionItemWasCalled = false
        lastAddedMealLog = nil
        lastRemovedMealLog = nil
        lastInsertedOption = nil
        lastDeletedOption = nil
        lastInsertedItem = nil
        lastDeletedItem = nil
    }

    func fetchLog(for date: Date) async throws -> DailyNutritionLog? {
        fetchLogWasCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedLog
    }

    func saveLog(_ log: DailyNutritionLog) async throws {
        saveLogWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }

    func addMealLog(_ mealLog: MealLog, to log: DailyNutritionLog) async throws {
        addMealLogWasCalled = true
        lastAddedMealLog = mealLog
        if shouldThrowError { throw errorToThrow }
    }

    func removeMealLog(_ mealLog: MealLog) async throws {
        removeMealLogWasCalled = true
        lastRemovedMealLog = mealLog
        if shouldThrowError { throw errorToThrow }
    }

    func save() async throws {
        saveWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }

    func insertMealOption(_ option: MealOption) async throws {
        insertMealOptionWasCalled = true
        lastInsertedOption = option
        if shouldThrowError { throw errorToThrow }
    }

    func deleteMealOption(_ option: MealOption) async throws {
        deleteMealOptionWasCalled = true
        lastDeletedOption = option
        if shouldThrowError { throw errorToThrow }
    }

    func insertMealOptionItem(_ item: MealOptionItem) async throws {
        insertMealOptionItemWasCalled = true
        lastInsertedItem = item
        if shouldThrowError { throw errorToThrow }
    }

    func deleteMealOptionItem(_ item: MealOptionItem) async throws {
        deleteMealOptionItemWasCalled = true
        lastDeletedItem = item
        if shouldThrowError { throw errorToThrow }
    }
}

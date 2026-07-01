//
//  MealDetailTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension MealDetailTests {

    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {

        // MARK: - Subject Under Test

        let sut: MealDetailInteractor

        // MARK: - Spies

        let spy: SpyNutritionRepository

        // MARK: - Initializers

        init() {
            spy = SpyNutritionRepository()
            sut = MealDetailInteractor(nutritionRepository: spy)
        }

        @Test("fetchLog delegates to repository")
        func fetchLogTracked() async throws {
            _ = try await sut.fetchLog(for: .now)
            #expect(spy.fetchLogWasCalled == true)
        }

        @Test("fetchLog propagates error")
        func fetchLogPropagatesError() async {
            spy.shouldThrowError = true
            spy.errorToThrow = NutritionError.loadFailed
            await #expect(throws: NutritionError.self) {
                _ = try await sut.fetchLog(for: .now)
            }
        }

        @Test("saveLog delegates to repository")
        func saveLogTracked() async throws {
            let log = DailyNutritionLog(date: .now)
            try await sut.saveLog(log)
            #expect(spy.saveLogWasCalled == true)
        }

        @Test("addMealLog delegates to repository")
        func addMealLogTracked() async throws {
            let log = DailyNutritionLog(date: .now)
            let mealLog = MealLog(wasFollowed: true)
            try await sut.addMealLog(mealLog, to: log)
            #expect(spy.addMealLogWasCalled == true)
            #expect(spy.lastAddedMealLog?.id == mealLog.id)
        }

        @Test("removeMealLog delegates to repository")
        func removeMealLogTracked() async throws {
            let mealLog = MealLog(wasFollowed: true)
            try await sut.removeMealLog(mealLog)
            #expect(spy.removeMealLogWasCalled == true)
            #expect(spy.lastRemovedMealLog?.id == mealLog.id)
        }

        @Test("save delegates to repository")
        func saveTracked() async throws {
            try await sut.save()
            #expect(spy.saveWasCalled == true)
        }

        @Test("insertMealOption delegates to repository")
        func insertMealOptionTracked() async throws {
            let option = MealOption(optionNumber: 2)
            try await sut.insertMealOption(option)
            #expect(spy.insertMealOptionWasCalled == true)
            #expect(spy.lastInsertedOption?.id == option.id)
        }

        @Test("deleteMealOption delegates to repository")
        func deleteMealOptionTracked() async throws {
            let option = MealOption(optionNumber: 2)
            try await sut.deleteMealOption(option)
            #expect(spy.deleteMealOptionWasCalled == true)
        }

        @Test("insertMealOptionItem delegates to repository")
        func insertMealOptionItemTracked() async throws {
            let item = MealOptionItem(amountGrams: 100)
            try await sut.insertMealOptionItem(item)
            #expect(spy.insertMealOptionItemWasCalled == true)
        }

        @Test("deleteMealOptionItem delegates to repository")
        func deleteMealOptionItemTracked() async throws {
            let item = MealOptionItem(amountGrams: 100)
            try await sut.deleteMealOptionItem(item)
            #expect(spy.deleteMealOptionItemWasCalled == true)
        }
    }
}

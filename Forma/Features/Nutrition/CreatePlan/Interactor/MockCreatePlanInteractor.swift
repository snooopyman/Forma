//
//  MockCreatePlanInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

final class MockCreatePlanInteractor: CreatePlanInteractorProtocol {

    // MARK: - Stub Data

    nonisolated(unsafe) var shouldThrow = false

    // MARK: - Functions

    func savePlan(_ plan: NutritionPlan) async throws {
        if shouldThrow { throw NutritionError.saveFailed }
    }

    func setActivePlan(_ plan: NutritionPlan) async throws {
        if shouldThrow { throw NutritionError.saveFailed }
    }
}

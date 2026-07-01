//
//  SpyCreatePlanInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyCreatePlanInteractor: CreatePlanInteractorProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var savePlanWasCalled = false
    private(set) var setActivePlanWasCalled = false
    private(set) var lastSavedPlan: NutritionPlan?

    // MARK: - Stub Data

    var shouldThrowError = false
    var errorToThrow: Error = NutritionError.saveFailed

    // MARK: - Functions

    func reset() {
        savePlanWasCalled = false
        setActivePlanWasCalled = false
        lastSavedPlan = nil
    }

    func savePlan(_ plan: NutritionPlan) async throws {
        savePlanWasCalled = true
        lastSavedPlan = plan
        if shouldThrowError { throw errorToThrow }
    }

    func setActivePlan(_ plan: NutritionPlan) async throws {
        setActivePlanWasCalled = true
        if shouldThrowError { throw errorToThrow }
    }
}

//
//  CreatePlanInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol CreatePlanInteractorProtocol: Sendable {
    func savePlan(_ plan: NutritionPlan) async throws
    func setActivePlan(_ plan: NutritionPlan) async throws
}

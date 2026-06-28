//
//  EditPlanInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol EditPlanInteractorProtocol: Sendable {
    func save() async throws
    func insertMeal(_ meal: Meal) async throws
    func deleteMeal(_ meal: Meal) async throws
}

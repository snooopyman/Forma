//
//  FoodBrowserInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol FoodBrowserInteractorProtocol: Sendable {
    func fetchAllItems() async throws -> [FoodItem]
}

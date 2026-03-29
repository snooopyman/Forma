//
//  FoodItemRepositoryProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation

protocol FoodItemRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [FoodItem]
    func search(query: String) async throws -> [FoodItem]

    func save(_ item: FoodItem) async throws
    func delete(_ item: FoodItem) async throws
}

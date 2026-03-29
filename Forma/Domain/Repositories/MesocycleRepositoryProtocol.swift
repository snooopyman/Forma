//
//  MesocycleRepositoryProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import Foundation

protocol MesocycleRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Mesocycle]
    func fetchActive() async throws -> Mesocycle?

    func save(_ mesocycle: Mesocycle) async throws
    func delete(_ mesocycle: Mesocycle) async throws

    func setActive(_ mesocycle: Mesocycle) async throws
    func pause(_ mesocycle: Mesocycle) async throws
    func resume(_ mesocycle: Mesocycle) async throws
}

//
//  MesocycleListInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol MesocycleListInteractorProtocol: Sendable {
    func fetchMesocycles() async throws -> [Mesocycle]
    func deleteMesocycle(_ mesocycle: Mesocycle) async throws
    func setActiveMesocycle(_ mesocycle: Mesocycle) async throws
}

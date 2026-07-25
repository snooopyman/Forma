//
//  MuscleVolumeTargetRepositoryProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 25/7/26.
//

import Foundation

protocol MuscleVolumeTargetRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [MuscleVolumeTarget]
    func save(_ target: MuscleVolumeTarget) async throws
    func delete(_ target: MuscleVolumeTarget) async throws
}

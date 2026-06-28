//
//  ProgressInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol ProgressInteractorProtocol: Sendable {
    func fetchMeasurements() async throws -> [BodyMeasurement]
    func deleteMeasurement(_ measurement: BodyMeasurement) async throws
}

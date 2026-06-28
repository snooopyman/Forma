//
//  NewMeasurementInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

protocol NewMeasurementInteractorProtocol: Sendable {
    func fetchProfile() async throws -> UserProfile?
    func fetchLatestWeight() async -> Double?
    func saveMeasurement(_ measurement: BodyMeasurement) async throws
    func updateMeasurement(_ measurement: BodyMeasurement) async throws
    func writeWeight(_ kg: Double, date: Date) async
}

//
//  ProgressOverviewViewModelProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import SwiftUI

@MainActor
protocol ProgressOverviewViewModelProtocol: AnyObject {
    var measurements: [BodyMeasurement] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    var latest: BodyMeasurement? { get }
    var weightDelta: Double? { get }
    var bodyFatDelta: Double? { get }
    
    func load() async
    func delete(_ measurement: BodyMeasurement) async
}

// MARK: - @Entry

extension EnvironmentValues {
    @Entry var progressOverviewViewModel: (any ProgressOverviewViewModelProtocol)? = nil
}

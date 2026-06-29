//
//  MockProgressOverviewViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

@Observable
@MainActor
final class MockProgressOverviewViewModel: ProgressOverviewViewModelProtocol {

    // MARK: - States

    var measurements: [BodyMeasurement] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var latest: BodyMeasurement? { measurements.first }

    var weightDelta: Double? {
        guard measurements.count >= 2 else { return nil }
        return measurements[0].weightKg - measurements[1].weightKg
    }

    var bodyFatDelta: Double? {
        guard measurements.count >= 2,
              let current = measurements[0].bodyFatPercent,
              let previous = measurements[1].bodyFatPercent else { return nil }
        return current - previous
    }

    // MARK: - Functions

    func load() async { }

    func delete(_ measurement: BodyMeasurement) async {
        measurements.removeAll { $0.id == measurement.id }
    }
}

// MARK: - Preview Factories

extension MockProgressOverviewViewModel {
    static var empty: MockProgressOverviewViewModel { MockProgressOverviewViewModel() }

    static var loading: MockProgressOverviewViewModel {
        let vm = MockProgressOverviewViewModel()
        vm.isLoading = true
        return vm
    }

    static var withData: MockProgressOverviewViewModel { MockProgressOverviewViewModel() }

    static var withError: MockProgressOverviewViewModel {
        let vm = MockProgressOverviewViewModel()
        vm.errorMessage = String(localized: "Could not load progress data")
        return vm
    }
}

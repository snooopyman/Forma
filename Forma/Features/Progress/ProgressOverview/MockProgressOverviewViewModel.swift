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

    static var withData: MockProgressOverviewViewModel {
        let vm = MockProgressOverviewViewModel()

        let entries: [(daysAgo: Int, kg: Double, waist: Double, abdomen: Double, neck: Double)] = [
            (0,  81.8, 80.0, 85.0, 38.5),
            (7,  81.4, 80.5, 85.5, 38.4),
            (14, 81.0, 80.8, 86.0, 38.4),
            (21, 80.5, 81.2, 86.5, 38.2),
            (28, 80.1, 81.5, 87.0, 38.2),
            (35, 79.8, 81.8, 87.5, 38.0),
            (42, 79.2, 82.0, 88.0, 38.0)
        ]
        vm.measurements = entries.map { entry in
            BodyMeasurement(
                date: Calendar.current.date(byAdding: .day, value: -entry.daysAgo, to: .now)!,
                weightKg: entry.kg,
                heightCm: 178,
                biologicalSex: .male,
                neckCm: entry.neck,
                armCm: 36.0,
                waistCm: entry.waist,
                abdomenCm: entry.abdomen
            )
        }

        return vm
    }

    static var withError: MockProgressOverviewViewModel {
        let vm = MockProgressOverviewViewModel()
        vm.errorMessage = L10n.Progress.Error.loadFailed
        return vm
    }
}

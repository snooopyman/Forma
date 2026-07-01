//
//  MockMesocycleListViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import Foundation

@Observable
@MainActor
final class MockMesocycleListViewModel: MesocycleListViewModelProtocol {

    // MARK: - States

    var mesocycles: [Mesocycle] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var activeMesocycle: Mesocycle? { mesocycles.first { $0.isActive } }

    // MARK: - Functions

    func load() async { }

    func delete(_ mesocycle: Mesocycle) async {
        mesocycles.removeAll { $0.id == mesocycle.id }
    }

    func setActive(_ mesocycle: Mesocycle) async {
        mesocycles.forEach { $0.isActive = false }
        mesocycles.first { $0.id == mesocycle.id }?.isActive = true
    }
}

// MARK: - Preview Factories

extension MockMesocycleListViewModel {
    static var empty: MockMesocycleListViewModel { MockMesocycleListViewModel() }

    static var loading: MockMesocycleListViewModel {
        let vm = MockMesocycleListViewModel()
        vm.isLoading = true
        return vm
    }

    static var withData: MockMesocycleListViewModel {
        let vm = MockMesocycleListViewModel()

        let active = Mesocycle(
            name: "Hipertrofia Bloque 1",
            startDate: Calendar.current.date(byAdding: .day, value: -14, to: .now)!,
            durationWeeks: 6,
            useFixedDays: false,
            isActive: true
        )

        let paused = Mesocycle(
            name: "Fuerza Bloque 4",
            startDate: Calendar.current.date(byAdding: .day, value: -21, to: .now)!,
            durationWeeks: 8,
            useFixedDays: true,
            isActive: false
        )
        paused.pausedAt = Calendar.current.date(byAdding: .day, value: -5, to: .now)

        let completed = Mesocycle(
            name: "Volumen Bloque 3",
            startDate: Calendar.current.date(byAdding: .weekOfYear, value: -10, to: .now)!,
            durationWeeks: 6,
            useFixedDays: false,
            isActive: false
        )

        vm.mesocycles = [active, paused, completed]

        return vm
    }

    static var withError: MockMesocycleListViewModel {
        let vm = MockMesocycleListViewModel()
        vm.errorMessage = L10n.Training.Error.loadFailed
        return vm
    }
}

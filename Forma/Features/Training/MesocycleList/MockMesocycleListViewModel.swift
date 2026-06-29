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

    static var withData: MockMesocycleListViewModel { MockMesocycleListViewModel() }

    static var withError: MockMesocycleListViewModel {
        let vm = MockMesocycleListViewModel()
        vm.errorMessage = String(localized: "Could not load training data")
        return vm
    }
}

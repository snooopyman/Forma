//
//  MesocycleListViewModelProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import SwiftUI

@MainActor
protocol MesocycleListViewModelProtocol: AnyObject {
    var mesocycles: [Mesocycle] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    var activeMesocycle: Mesocycle? { get }
    
    func load() async
    func delete(_ mesocycle: Mesocycle) async
    func setActive(_ mesocycle: Mesocycle) async
}

// MARK: - @Entry

extension EnvironmentValues {
    @Entry var mesocycleListViewModel: (any MesocycleListViewModelProtocol)? = nil
}

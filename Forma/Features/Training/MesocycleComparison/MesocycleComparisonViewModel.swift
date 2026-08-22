//
//  MesocycleComparisonViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 17/8/26.
//

import Foundation

@Observable
@MainActor
final class MesocycleComparisonViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: MesocycleComparisonInteractorProtocol
    
    // MARK: - States
    
    var selectedMuscle: MuscleGroup
    
    // MARK: - Properties
    
    let snapshot: MesocycleComparisonSnapshot
    
    // MARK: - Initializers
    
    init(interactor: MesocycleComparisonInteractorProtocol, mesocycles: [Mesocycle]) {
        self.interactor = interactor
        self.snapshot = interactor.buildSnapshot(for: mesocycles)
        self.selectedMuscle = MuscleGroup.comparable.first ?? .chest
    }
}

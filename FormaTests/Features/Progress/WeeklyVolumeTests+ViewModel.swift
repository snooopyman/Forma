//
//  WeeklyVolumeTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 25/7/26.
//

import Testing
import Foundation
@testable import Forma

extension WeeklyVolumeTests {
    
    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {
        
        // MARK: - Subject Under Test
        
        let sut: WeeklyVolumeViewModel
        
        // MARK: - Spies
        
        let spy: SpyWeeklyVolumeInteractor
        
        // MARK: - Initializers
        
        init() {
            spy = SpyWeeklyVolumeInteractor()
            sut = WeeklyVolumeViewModel(interactor: spy)
        }
        
        @Test("load() fetches the snapshot")
        func loadSuccess() async {
            spy.stubbedSnapshot = WeeklyVolumeSnapshot(
                weekRange: .now..<(.now),
                coachings: [MuscleVolumeCoaching(muscleGroup: .chest, actualSets: 10, target: nil, state: nil)],
                hasCompletedSessionsThisWeek: true,
                hasTargetsConfigured: true
            )
            await sut.load()
            #expect(spy.loadSnapshotWasCalled == true)
            #expect(sut.snapshot?.coachings.count == 1)
            #expect(sut.isLoading == false)
        }
        
        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = ProgressError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == ProgressError.loadFailed.errorDescription)
        }
        
        @Test("setUpDefaultTargets() seeds and reloads")
        func setUpDefaultTargets() async {
            await sut.setUpDefaultTargets()
            #expect(spy.seedDefaultTargetsWasCalled == true)
            #expect(spy.loadSnapshotWasCalled == true)
            #expect(spy.fetchTargetsWasCalled == true)
        }
        
        @Test("restoreDefaultTargets() restores and reloads")
        func restoreDefaultTargets() async {
            await sut.restoreDefaultTargets()
            #expect(spy.restoreDefaultTargetsWasCalled == true)
            #expect(spy.loadSnapshotWasCalled == true)
        }
        
        @Test("save() delegates to the interactor")
        func save() async {
            let target = MuscleVolumeTarget(muscleGroup: .chest, mevSets: 8, mavSets: 16, mrvSets: 22)
            await sut.save(target)
            #expect(spy.saveTargetWasCalled == true)
            #expect(spy.lastSavedTarget?.muscleGroup == .chest)
        }
        
        @Test("sortedTargets orders by MuscleGroup.allCases")
        func sortedTargets() async {
            spy.stubbedTargets = [
                MuscleVolumeTarget(muscleGroup: .calves, mevSets: 0, mavSets: 0, mrvSets: 0),
                MuscleVolumeTarget(muscleGroup: .chest, mevSets: 0, mavSets: 0, mrvSets: 0)
            ]
            await sut.loadTargets()
            #expect(sut.sortedTargets.first?.muscleGroup == .chest)
        }
    }
}

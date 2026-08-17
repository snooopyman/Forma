//
//  PhotoComparisonTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 12/8/26.
//

import Testing
import Foundation
@testable import Forma

extension PhotoComparisonTests {
    
    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {
        
        // MARK: - Spies
        
        let spy: SpyPhotoComparisonInteractor
        
        // MARK: - Initializers
        
        init() {
            spy = SpyPhotoComparisonInteractor()
        }
        
        @Test("init uses the interactor's suggested pair")
        func initUsesSuggestedPair() {
            let before = makePhoto(angle: .front)
            let after = makePhoto(angle: .front)
            spy.stubbedPair = (before: before, after: after)
            
            let sut = PhotoComparisonViewModel(interactor: spy, photos: [before, after])
            
            #expect(spy.suggestedPairWasCalled == true)
            #expect(sut.beforePhoto.id == before.id)
            #expect(sut.afterPhoto.id == after.id)
        }
        
        @Test("loadMeasurements populates before/after measurements and the delta")
        func loadMeasurementsPopulates() async {
            let before = makePhoto(angle: .front)
            let after = makePhoto(angle: .front)
            spy.stubbedPair = (before: before, after: after)
            let beforeMeasurement = makeMeasurement(weightKg: 80)
            let afterMeasurement = makeMeasurement(weightKg: 78)
            spy.stubbedMeasurements = (beforeMeasurement, afterMeasurement)
            let sut = PhotoComparisonViewModel(interactor: spy, photos: [before, after])
            
            await sut.loadMeasurements()
            
            #expect(sut.beforeMeasurement?.id == beforeMeasurement.id)
            #expect(sut.afterMeasurement?.id == afterMeasurement.id)
            #expect(sut.weightDelta == -2)
        }
        
        @Test("weightDelta is nil unless both sides have a match")
        func weightDeltaRequiresBothSides() async {
            let before = makePhoto(angle: .front)
            let after = makePhoto(angle: .front)
            spy.stubbedPair = (before: before, after: after)
            spy.stubbedMeasurements = (makeMeasurement(weightKg: 80), nil)
            let sut = PhotoComparisonViewModel(interactor: spy, photos: [before, after])
            
            await sut.loadMeasurements()
            
            #expect(sut.weightDelta == nil)
        }
        
        @Test("swapPhotos exchanges before/after photos and measurements")
        func swapPhotosExchanges() async {
            let before = makePhoto(angle: .front)
            let after = makePhoto(angle: .back)
            spy.stubbedPair = (before: before, after: after)
            let beforeMeasurement = makeMeasurement(weightKg: 80)
            let afterMeasurement = makeMeasurement(weightKg: 78)
            spy.stubbedMeasurements = (beforeMeasurement, afterMeasurement)
            let sut = PhotoComparisonViewModel(interactor: spy, photos: [before, after])
            await sut.loadMeasurements()
            
            sut.swapPhotos()
            
            #expect(sut.beforePhoto.id == after.id)
            #expect(sut.afterPhoto.id == before.id)
            #expect(sut.beforeMeasurement?.id == afterMeasurement.id)
            #expect(sut.afterMeasurement?.id == beforeMeasurement.id)
            #expect(sut.swapCount == 1)
        }
        
        @Test("selectBefore updates the before photo and reloads measurements")
        func selectBeforeReloads() async {
            let before = makePhoto(angle: .front)
            let after = makePhoto(angle: .front)
            spy.stubbedPair = (before: before, after: after)
            let sut = PhotoComparisonViewModel(interactor: spy, photos: [before, after])
            let newBefore = makePhoto(angle: .front)
            spy.stubbedMeasurements = (makeMeasurement(weightKg: 70), nil)
            
            await sut.selectBefore(newBefore)
            
            #expect(sut.beforePhoto.id == newBefore.id)
            #expect(spy.lastNearestMeasurementsBefore?.id == newBefore.id)
        }
        
        @Test("selectAfter updates the after photo and reloads measurements")
        func selectAfterReloads() async {
            let before = makePhoto(angle: .front)
            let after = makePhoto(angle: .front)
            spy.stubbedPair = (before: before, after: after)
            let sut = PhotoComparisonViewModel(interactor: spy, photos: [before, after])
            let newAfter = makePhoto(angle: .front)
            spy.stubbedMeasurements = (nil, makeMeasurement(weightKg: 70))
            
            await sut.selectAfter(newAfter)
            
            #expect(sut.afterPhoto.id == newAfter.id)
            #expect(spy.lastNearestMeasurementsAfter?.id == newAfter.id)
        }
    }
}

// MARK: - Test Helpers

private extension PhotoComparisonTests.ViewModelTests {
    func makePhoto(angle: PhotoAngle) -> ProgressPhoto {
        ProgressPhoto(date: .now, angle: angle, imageData: Data())
    }
    
    func makeMeasurement(weightKg: Double) -> BodyMeasurement {
        BodyMeasurement(date: .now, weightKg: weightKg, heightCm: 180, biologicalSex: .male)
    }
}

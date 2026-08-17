//
//  SpyPhotoComparisonInteractor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 12/8/26.
//

import Foundation
@testable import Forma

final class SpyPhotoComparisonInteractor: PhotoComparisonInteractorProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var suggestedPairWasCalled = false
    private(set) var nearestMeasurementsWasCalled = false
    private(set) var lastNearestMeasurementsBefore: ProgressPhoto?
    private(set) var lastNearestMeasurementsAfter: ProgressPhoto?
    
    // MARK: - Stub Data
    
    var stubbedPair: (before: ProgressPhoto, after: ProgressPhoto)?
    var stubbedMeasurements: (before: BodyMeasurement?, after: BodyMeasurement?) = (nil, nil)
    
    // MARK: - Functions
    
    func suggestedPair(from photos: [ProgressPhoto]) -> (before: ProgressPhoto, after: ProgressPhoto)? {
        suggestedPairWasCalled = true
        return stubbedPair
    }
    
    func nearestMeasurements(before: ProgressPhoto, after: ProgressPhoto) async -> (before: BodyMeasurement?, after: BodyMeasurement?) {
        nearestMeasurementsWasCalled = true
        lastNearestMeasurementsBefore = before
        lastNearestMeasurementsAfter = after
        return stubbedMeasurements
    }
}

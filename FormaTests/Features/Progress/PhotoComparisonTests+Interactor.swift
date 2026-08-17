//
//  PhotoComparisonTests+Interactor.swift
//  FormaTests
//
//  Created by Armando Cáceres on 12/8/26.
//

import Testing
import Foundation
@testable import Forma

extension PhotoComparisonTests {
    
    @Suite("Interactor Tests")
    @MainActor
    struct InteractorTests {
        
        // MARK: - Subject Under Test
        
        let sut: PhotoComparisonInteractor
        
        // MARK: - Spies
        
        let spy: SpyBodyMeasurementRepository
        
        // MARK: - Initializers
        
        init() {
            spy = SpyBodyMeasurementRepository()
            sut = PhotoComparisonInteractor(measurementRepository: spy)
        }
        
        // MARK: - suggestedPair
        
        @Test("suggestedPair picks the angle with the most photos, oldest vs newest")
        func suggestedPairSameAngleMultiplePhotos() {
            let old = makePhoto(daysAgo: 60, angle: .front)
            let mid = makePhoto(daysAgo: 30, angle: .front)
            let recent = makePhoto(daysAgo: 1, angle: .front)
            let other = makePhoto(daysAgo: 10, angle: .back)
            
            let pair = sut.suggestedPair(from: [mid, other, recent, old])
            
            #expect(pair?.before.id == old.id)
            #expect(pair?.after.id == recent.id)
        }
        
        @Test("suggestedPair returns nil when no single angle has 2+ photos, even if the total is 2+")
        func suggestedPairNoEligibleAngle() {
            let front = makePhoto(daysAgo: 60, angle: .front)
            let back = makePhoto(daysAgo: 1, angle: .back)
            
            let pair = sut.suggestedPair(from: [front, back])
            
            #expect(pair == nil)
        }
        
        @Test("suggestedPair breaks ties between angles using sortOrder")
        func suggestedPairTieBreakBySortOrder() {
            // front sortOrder (0) beats back sortOrder (1) when both have 2 photos
            let backOld = makePhoto(daysAgo: 60, angle: .back)
            let backNew = makePhoto(daysAgo: 1, angle: .back)
            let frontOld = makePhoto(daysAgo: 50, angle: .front)
            let frontNew = makePhoto(daysAgo: 2, angle: .front)
            
            let pair = sut.suggestedPair(from: [backOld, backNew, frontOld, frontNew])
            
            #expect(pair?.before.id == frontOld.id)
            #expect(pair?.after.id == frontNew.id)
        }
        
        @Test("suggestedPair does not depend on the input array order")
        func suggestedPairOrderIndependent() {
            let old = makePhoto(daysAgo: 60, angle: .front)
            let recent = makePhoto(daysAgo: 1, angle: .front)
            
            let pairA = sut.suggestedPair(from: [old, recent])
            let pairB = sut.suggestedPair(from: [recent, old])
            
            #expect(pairA?.before.id == pairB?.before.id)
            #expect(pairA?.after.id == pairB?.after.id)
        }
        
        @Test("suggestedPair returns nil with fewer than 2 photos")
        func suggestedPairInsufficientPhotos() {
            let pair = sut.suggestedPair(from: [makePhoto(daysAgo: 0, angle: .front)])
            #expect(pair == nil)
        }
        
        // MARK: - nearestMeasurement
        
        @Test("nearestMeasurement uses real days, not calendar month buckets")
        func nearestMeasurementRealDays() {
            var components = DateComponents(year: 2026, month: 1, day: 30)
            let measurementDate = Calendar.current.date(from: components)!
            let measurement = BodyMeasurement(date: measurementDate, weightKg: 80, heightCm: 180, biologicalSex: .male)
            
            components.day = 31
            let jan31 = Calendar.current.date(from: components)!
            components.month = 2
            components.day = 1
            let feb1 = Calendar.current.date(from: components)!
            
            #expect(sut.nearestMeasurement(to: jan31, in: [measurement])?.id == measurement.id)
            #expect(sut.nearestMeasurement(to: feb1, in: [measurement])?.id == measurement.id)
        }
        
        @Test("nearestMeasurement respects the ±10 day tolerance")
        func nearestMeasurementTolerance() {
            let farMeasurement = makeMeasurement(daysAgo: 11, weightKg: 90)
            #expect(sut.nearestMeasurement(to: .now, in: [farMeasurement]) == nil)
            
            let closeMeasurement = makeMeasurement(daysAgo: 10, weightKg: 85)
            #expect(sut.nearestMeasurement(to: .now, in: [closeMeasurement])?.id == closeMeasurement.id)
        }
        
        @Test("nearestMeasurement prefers the earlier measurement on an exact distance tie")
        func nearestMeasurementTieBreak() {
            let calendar = Calendar.current
            let target = Date.now
            let before = BodyMeasurement(
                date: calendar.date(byAdding: .day, value: -3, to: target)!,
                weightKg: 80, heightCm: 180, biologicalSex: .male
            )
            let after = BodyMeasurement(
                date: calendar.date(byAdding: .day, value: 3, to: target)!,
                weightKg: 81, heightCm: 180, biologicalSex: .male
            )
            
            let nearest = sut.nearestMeasurement(to: target, in: [after, before])
            
            #expect(nearest?.id == before.id)
        }
        
        @Test("nearestMeasurements returns nil for both sides when the repository throws")
        func nearestMeasurementsRepositoryFailure() async {
            spy.shouldThrowError = true
            let photoA = makePhoto(daysAgo: 5, angle: .front)
            let photoB = makePhoto(daysAgo: 1, angle: .front)
            
            let result = await sut.nearestMeasurements(before: photoA, after: photoB)
            
            #expect(result.before == nil)
            #expect(result.after == nil)
        }
    }
}

// MARK: - Test Helpers

private extension PhotoComparisonTests.InteractorTests {
    func makePhoto(daysAgo: Int, angle: PhotoAngle) -> ProgressPhoto {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
        return ProgressPhoto(date: date, angle: angle, imageData: Data())
    }
    
    func makeMeasurement(daysAgo: Int, weightKg: Double) -> BodyMeasurement {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
        return BodyMeasurement(date: date, weightKg: weightKg, heightCm: 180, biologicalSex: .male)
    }
}

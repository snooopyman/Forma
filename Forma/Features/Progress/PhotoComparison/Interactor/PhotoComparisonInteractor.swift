//
//  PhotoComparisonInteractor.swift
//  Forma
//
//  Created by Armando Cáceres on 12/8/26.
//

import Foundation
import OSLog

final class PhotoComparisonInteractor: PhotoComparisonInteractorProtocol {
    
    // MARK: - Private Properties
    
    private let measurementRepository: BodyMeasurementRepositoryProtocol
    
    // MARK: - Initializers
    
    init(measurementRepository: BodyMeasurementRepositoryProtocol) {
        self.measurementRepository = measurementRepository
    }
    
    // MARK: - Functions
    
    func suggestedPair(from photos: [ProgressPhoto]) -> (before: ProgressPhoto, after: ProgressPhoto)? {
        guard photos.count >= 2 else { return nil }
        let sorted = photos.sorted { $0.date < $1.date }
        let grouped = Dictionary(grouping: sorted, by: \.angle)
        let eligibleAngles = grouped.filter { $0.value.count >= 2 }
        
        guard let bestAngle = eligibleAngles.keys.sorted(by: { lhs, rhs in
            let lhsCount = eligibleAngles[lhs]?.count ?? 0
            let rhsCount = eligibleAngles[rhs]?.count ?? 0
            if lhsCount != rhsCount { return lhsCount > rhsCount }
            return lhs.sortOrder < rhs.sortOrder
        }).first,
              let anglePhotos = eligibleAngles[bestAngle],
              let first = anglePhotos.first,
              let last = anglePhotos.last
        else {
            return nil
        }
        
        return (before: first, after: last)
    }
    
    func nearestMeasurements(before: ProgressPhoto, after: ProgressPhoto) async -> (before: BodyMeasurement?, after: BodyMeasurement?) {
        do {
            let measurements = try await measurementRepository.fetchAll()
            return (
                nearestMeasurement(to: before.date, in: measurements),
                nearestMeasurement(to: after.date, in: measurements)
            )
        } catch {
            Logger.progress.error("Failed to fetch measurements for photo comparison: \(error, privacy: .public)")
            return (nil, nil)
        }
    }
    
    func nearestMeasurement(
        to date: Date,
        in measurements: [BodyMeasurement],
        toleranceDays: Int = 10
    ) -> BodyMeasurement? {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        
        var best: (measurement: BodyMeasurement, distance: Int, isBefore: Bool)?
        for measurement in measurements {
            let measurementDay = calendar.startOfDay(for: measurement.date)
            let days = calendar.dateComponents([.day], from: measurementDay, to: targetDay).day ?? 0
            let distance = abs(days)
            guard distance <= toleranceDays else { continue }
            let isBefore = days >= 0
            
            guard let current = best else {
                best = (measurement, distance, isBefore)
                continue
            }
            if distance < current.distance || (distance == current.distance && isBefore && !current.isBefore) {
                best = (measurement, distance, isBefore)
            }
        }
        return best?.measurement
    }
}

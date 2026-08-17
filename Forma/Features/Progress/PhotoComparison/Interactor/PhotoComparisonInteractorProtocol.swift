//
//  PhotoComparisonInteractorProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 12/8/26.
//

import Foundation

protocol PhotoComparisonInteractorProtocol: Sendable {
    func suggestedPair(from photos: [ProgressPhoto]) -> (before: ProgressPhoto, after: ProgressPhoto)?
    func nearestMeasurements(before: ProgressPhoto, after: ProgressPhoto) async -> (before: BodyMeasurement?, after: BodyMeasurement?)
}

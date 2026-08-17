//
//  PhotoComparisonViewModel.swift
//  Forma
//
//  Created by Armando Cáceres on 12/8/26.
//

import Foundation

@Observable
@MainActor
final class PhotoComparisonViewModel {
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private let interactor: PhotoComparisonInteractorProtocol
    
    // MARK: - States
    
    var beforePhoto: ProgressPhoto
    var afterPhoto: ProgressPhoto
    var beforeMeasurement: BodyMeasurement?
    var afterMeasurement: BodyMeasurement?
    var swapCount = 0
    
    // MARK: - Properties
    
    let allPhotos: [ProgressPhoto]
    
    // MARK: - Computed Properties
    
    var weightDelta: Double? {
        guard let before = beforeMeasurement?.weightKg, let after = afterMeasurement?.weightKg else { return nil }
        return after - before
    }
    
    // MARK: - Initializers
    
    init(interactor: PhotoComparisonInteractorProtocol, photos: [ProgressPhoto]) {
        self.interactor = interactor
        self.allPhotos = photos
        let pair = interactor.suggestedPair(from: photos) ?? (before: photos[0], after: photos[0])
        self.beforePhoto = pair.before
        self.afterPhoto = pair.after
    }
    
    // MARK: - Functions
    
    func loadMeasurements() async {
        let matches = await interactor.nearestMeasurements(before: beforePhoto, after: afterPhoto)
        beforeMeasurement = matches.before
        afterMeasurement = matches.after
    }
    
    func swapPhotos() {
        let previousBeforePhoto = beforePhoto
        beforePhoto = afterPhoto
        afterPhoto = previousBeforePhoto
        
        let previousBeforeMeasurement = beforeMeasurement
        beforeMeasurement = afterMeasurement
        afterMeasurement = previousBeforeMeasurement
        
        swapCount += 1
    }
    
    func selectBefore(_ photo: ProgressPhoto) async {
        beforePhoto = photo
        await loadMeasurements()
    }
    
    func selectAfter(_ photo: ProgressPhoto) async {
        afterPhoto = photo
        await loadMeasurements()
    }
}

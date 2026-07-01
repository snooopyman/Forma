//
//  SpyRestTimerActivityService.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Foundation
@testable import Forma

final class SpyRestTimerActivityService: RestTimerActivityServiceProtocol, @unchecked Sendable {

    // MARK: - Spy Tracking

    private(set) var startActivityWasCalled = false
    private(set) var endActivityWasCalled = false
    private(set) var lastExerciseName: String?
    private(set) var lastSeconds: Int?

    // MARK: - Functions

    func reset() {
        startActivityWasCalled = false
        endActivityWasCalled = false
        lastExerciseName = nil
        lastSeconds = nil
    }

    func startActivity(exerciseName: String, seconds: Int) async {
        startActivityWasCalled = true
        lastExerciseName = exerciseName
        lastSeconds = seconds
    }

    func endActivity() async {
        endActivityWasCalled = true
    }
}

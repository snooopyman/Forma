//
//  SpyMeasurementReminderScheduler.swift
//  FormaTests
//
//  Created by Armando Cáceres on 11/7/26.
//

import Foundation
@testable import Forma

final class SpyMeasurementReminderScheduler: MeasurementReminderSchedulerProtocol, @unchecked Sendable {
    
    // MARK: - Spy Tracking
    
    private(set) var rescheduleWasCalled = false
    
    // MARK: - Functions
    
    func reset() {
        rescheduleWasCalled = false
    }
    
    func reschedule() async {
        rescheduleWasCalled = true
    }
}

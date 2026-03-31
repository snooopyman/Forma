//
//  RestTimerActivityService.swift
//  Forma
//
//  Created by Armando Cáceres on 31/3/26.
//

@preconcurrency import ActivityKit
import Foundation
import OSLog

// MARK: - Protocol

protocol RestTimerActivityServiceProtocol: Sendable {
    func startActivity(exerciseName: String, seconds: Int) async
    func endActivity() async
}

// MARK: - Concrete Implementation

@MainActor
final class RestTimerActivityService: RestTimerActivityServiceProtocol {
    
    // MARK: - Private Properties
    
    private var currentActivity: Activity<RestTimerAttributes>?
    
    // MARK: - Functions
    
    func startActivity(exerciseName: String, seconds: Int) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        await endActivity()
        
        let attributes = RestTimerAttributes(exerciseName: exerciseName, totalSeconds: seconds)
        let endsAt = Date.now.addingTimeInterval(TimeInterval(seconds))
        let contentState = RestTimerAttributes.ContentState(endsAt: endsAt)
        let content = ActivityContent(state: contentState, staleDate: endsAt.addingTimeInterval(10))
        
        do {
            currentActivity = try Activity.request(attributes: attributes, content: content)
            Logger.training.info("Live Activity started for: \(exerciseName, privacy: .public)")
        } catch {
            Logger.training.error("Failed to start Live Activity: \(error, privacy: .private)")
        }
    }
    
    func endActivity() async {
        guard let activity = currentActivity else { return }
        await activity.end(nil, dismissalPolicy: .immediate)
        currentActivity = nil
    }
}

// MARK: - Mock

struct MockRestTimerActivityService: RestTimerActivityServiceProtocol {
    func startActivity(exerciseName: String, seconds: Int) async {}
    func endActivity() async {}
}

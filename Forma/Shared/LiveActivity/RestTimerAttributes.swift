//
//  RestTimerAttributes.swift
//  Forma
//
//  Created by Armando Cáceres on 31/3/26.
//

import ActivityKit
import Foundation

struct RestTimerAttributes: ActivityAttributes {

    // MARK: - Content State (dynamic — updated during the activity)

    struct ContentState: Codable, Hashable, Sendable {
        var endsAt: Date
    }

    // MARK: - Properties (static — set at activity start)

    var exerciseName: String
    var totalSeconds: Int
}

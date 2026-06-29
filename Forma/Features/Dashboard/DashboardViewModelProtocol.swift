//
//  DashboardViewModelProtocol.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//

import SwiftUI

@MainActor
protocol DashboardViewModelProtocol {
    var activeMesocycle: Mesocycle? { get }
    var todayWorkoutDay: WorkoutDay? { get }
    var inProgressSession: WorkoutSession? { get }
    var isTodaySessionCompleted: Bool { get }
    var macroSummary: DailyMacroSummary? { get }
    var hasActivePlan: Bool { get }
    var todaySteps: Int { get }
    var todayActiveCalories: Double { get }
    var todayExerciseMinutes: Double { get }
    var healthKitAuthorized: Bool { get }
    var showMeasurementReminder: Bool { get }
    var weeklyCompletedSessions: Int { get }
    var weeklyPlannedDays: Int { get }
    var isHealthKitAvailable: Bool { get }
    var greeting: String { get }
    var todayFormatted: String { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    
    func load() async
    func requestHealthKitAccess() async
}

// MARK: - @Entry

extension EnvironmentValues {
    @Entry var dashboardViewModel: (any DashboardViewModelProtocol)? = nil
}

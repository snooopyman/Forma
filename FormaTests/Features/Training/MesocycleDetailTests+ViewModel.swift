//
//  MesocycleDetailTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension MesocycleDetailTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: MesocycleDetailViewModel
        let spy: SpyMesocycleDetailInteractor
        let mesocycle: Mesocycle

        init() {
            spy = SpyMesocycleDetailInteractor()
            mesocycle = Mesocycle(name: "Block 1")
            sut = MesocycleDetailViewModel(mesocycle: mesocycle, interactor: spy)
        }

        @Test("load() fetches sessions and in-progress session")
        func loadSuccess() async {
            let session = WorkoutSession()
            spy.stubbedSessions = [session]
            await sut.load()
            #expect(spy.fetchSessionsWasCalled == true)
            #expect(spy.fetchInProgressSessionWasCalled == true)
            #expect(sut.sessions.count == 1)
            #expect(sut.isLoading == false)
        }

        @Test("load() sets errorMessage on failure")
        func loadFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.loadFailed
            await sut.load()
            #expect(sut.errorMessage == TrainingError.loadFailed.errorDescription)
        }

        @Test("activate() sets the mesocycle active")
        func activateSuccess() async {
            await sut.activate()
            #expect(spy.activateWasCalled == true)
            #expect(mesocycle.isActive == true)
        }

        @Test("pause() calls the interactor")
        func pauseSuccess() async {
            await sut.pause()
            #expect(spy.pauseWasCalled == true)
        }

        @Test("resume() calls the interactor")
        func resumeSuccess() async {
            await sut.resume()
            #expect(spy.resumeWasCalled == true)
        }

        @Test("addWorkoutDay() creates and adds a new day")
        func addWorkoutDaySuccess() async {
            await sut.addWorkoutDay(name: "Push", isRestDay: false, weekday: .monday)
            #expect(spy.addWorkoutDayWasCalled == true)
            #expect(spy.lastAddedDay?.name == "Push")
            #expect(mesocycle.workoutDays.count == 1)
        }

        @Test("addWorkoutDay() sets errorMessage on failure")
        func addWorkoutDayFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = TrainingError.saveFailed
            await sut.addWorkoutDay(name: "Push", isRestDay: false, weekday: .monday)
            #expect(sut.errorMessage == TrainingError.saveFailed.errorDescription)
        }

        @Test("completedSessionCount counts completed sessions for the given day")
        func completedSessionCount() async {
            let day = WorkoutDay(name: "Push", order: 0)
            let completedSession = WorkoutSession()
            completedSession.workoutDay = day
            completedSession.completedAt = .now
            let inProgressSession = WorkoutSession()
            inProgressSession.workoutDay = day
            spy.stubbedSessions = [completedSession, inProgressSession]
            await sut.load()
            #expect(sut.completedSessionCount(for: day) == 1)
        }
    }
}

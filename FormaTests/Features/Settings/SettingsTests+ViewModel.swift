//
//  SettingsTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension SettingsTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: SettingsViewModel
        let spy: SpySettingsInteractor

        init() {
            spy = SpySettingsInteractor()
            sut = SettingsViewModel(interactor: spy)
        }

        @Test("load() populates the profile")
        func loadSuccess() async {
            spy.stubbedProfile = UserProfile(name: "Ana", birthDate: .now, heightCm: 165, biologicalSex: .female)
            await sut.load()
            #expect(spy.loadProfileWasCalled == true)
            #expect(sut.profile?.name == "Ana")
        }

        @Test("load() leaves profile nil when interactor throws")
        func loadSwallowsError() async {
            spy.shouldThrowError = true
            await sut.load()
            #expect(sut.profile == nil)
        }

        @Test("isHealthKitAvailable/Authorized reflect the interactor")
        func healthKitFlags() {
            spy.isHealthKitAvailable = true
            spy.isHealthKitAuthorized = true
            #expect(sut.isHealthKitAvailable == true)
            #expect(sut.isHealthKitAuthorized == true)
        }

        @Test("requestHealthKitAccess() requests authorization")
        func requestHealthKitAccessSuccess() async {
            await sut.requestHealthKitAccess()
            #expect(spy.requestHealthKitAccessWasCalled == true)
            #expect(sut.isRequestingHealthKit == false)
            #expect(sut.healthKitError == nil)
        }

        @Test("requestHealthKitAccess() sets healthKitError on failure")
        func requestHealthKitAccessFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = SettingsError.loadFailed
            await sut.requestHealthKitAccess()
            #expect(sut.healthKitError == SettingsError.loadFailed.errorDescription)
        }
    }
}

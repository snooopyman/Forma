//
//  ProfileSetupTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension ProfileSetupTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: ProfileSetupViewModel
        let spy: SpyProfileSetupInteractor

        init() {
            spy = SpyProfileSetupInteractor()
            sut = ProfileSetupViewModel(interactor: spy)
        }

        @Test("advance increments currentStep")
        func advance() {
            sut.advance()
            #expect(sut.currentStep == 1)
        }

        @Test("goBack decrements currentStep")
        func goBack() {
            sut.advance()
            sut.goBack()
            #expect(sut.currentStep == 0)
        }

        @Test("canAdvanceFromName is false for blank name")
        func canAdvanceFromNameBlank() {
            sut.name = "   "
            #expect(sut.canAdvanceFromName == false)
        }

        @Test("connectHealthKit requests authorization")
        func connectHealthKit() async {
            await sut.connectHealthKit()
            #expect(spy.requestHealthKitAccessWasCalled == true)
        }

        @Test("connectHealthKit swallows errors silently")
        func connectHealthKitSwallowsError() async {
            spy.shouldThrowError = true
            await sut.connectHealthKit()
            #expect(sut.errorMessage == nil)
        }

        @Test("save() creates a new profile when none exists")
        func saveCreatesNewProfile() async {
            sut.name = "Ana"
            await sut.save()
            #expect(spy.fetchProfileWasCalled == true)
            #expect(spy.saveProfileWasCalled == true)
            #expect(spy.lastSavedProfile?.name == "Ana")
            #expect(sut.isSaving == false)
        }

        @Test("save() updates the existing profile")
        func saveUpdatesExistingProfile() async {
            let existing = UserProfile(name: "Old", birthDate: .now, heightCm: 160, biologicalSex: .female)
            spy.stubbedProfile = existing
            sut.name = "New Name"
            await sut.save()
            #expect(spy.lastSavedProfile?.id == existing.id)
            #expect(spy.lastSavedProfile?.name == "New Name")
        }

        @Test("save() sets errorMessage on failure")
        func saveFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = SettingsError.saveFailed
            sut.name = "Ana"
            await sut.save()
            #expect(sut.errorMessage == SettingsError.saveFailed.errorDescription)
        }
    }
}

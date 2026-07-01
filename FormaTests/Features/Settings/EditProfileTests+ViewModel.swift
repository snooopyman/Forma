//
//  EditProfileTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension EditProfileTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let sut: EditProfileViewModel
        let spy: SpyEditProfileInteractor
        let profile: UserProfile

        init() {
            spy = SpyEditProfileInteractor()
            profile = UserProfile(name: "Ana", birthDate: .now, heightCm: 165, biologicalSex: .female)
            sut = EditProfileViewModel(profile: profile, interactor: spy)
        }

        @Test("canSave is false for blank name")
        func canSaveBlankName() {
            sut.name = "  "
            #expect(sut.canSave == false)
        }

        @Test("save() persists changes and marks success")
        func saveSuccess() async {
            sut.name = "Ana Updated"
            sut.heightCm = 170
            await sut.save()
            #expect(spy.saveProfileWasCalled == true)
            #expect(profile.name == "Ana Updated")
            #expect(profile.heightCm == 170)
            #expect(sut.saveSucceeded == true)
            #expect(sut.errorMessage == nil)
        }

        @Test("save() does nothing when canSave is false")
        func saveInvalid() async {
            sut.name = ""
            await sut.save()
            #expect(spy.saveProfileWasCalled == false)
        }

        @Test("save() sets errorMessage on failure")
        func saveFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = SettingsError.saveFailed
            await sut.save()
            #expect(sut.errorMessage == SettingsError.saveFailed.errorDescription)
            #expect(sut.saveSucceeded == false)
        }
    }
}

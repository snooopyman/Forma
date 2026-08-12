//
//  NewMeasurementTests+ViewModel.swift
//  FormaTests
//
//  Created by Armando Cáceres on 1/7/26.
//

import Testing
import Foundation
@testable import Forma

extension NewMeasurementTests {

    @Suite("ViewModel Tests")
    @MainActor
    struct ViewModelTests {

        let spy: SpyNewMeasurementInteractor

        init() {
            spy = SpyNewMeasurementInteractor()
        }

        @Test("loadProfileHeight fills height and weight from profile/HealthKit")
        func loadProfileHeight() async {
            spy.stubbedProfile = UserProfile(name: "Ana", birthDate: .now, heightCm: 172, biologicalSex: .female)
            spy.stubbedLatestWeight = 65.0
            let sut = NewMeasurementViewModel(interactor: spy, onSaved: {})
            await sut.loadProfileHeight()
            #expect(spy.fetchProfileWasCalled == true)
            #expect(spy.fetchLatestWeightWasCalled == true)
            #expect(sut.heightText == "172")
            #expect(Double(sut.weightText.replacingOccurrences(of: ",", with: ".")) == 65.0)
        }

        @Test("save() with valid weight saves a new measurement")
        func saveNewMeasurement() async {
            var savedCalled = false
            let sut = NewMeasurementViewModel(interactor: spy, onSaved: { savedCalled = true })
            sut.weightText = "80"
            await sut.save()
            #expect(spy.saveMeasurementWasCalled == true)
            #expect(spy.writeWeightWasCalled == true)
            #expect(savedCalled == true)
            #expect(sut.errorMessage == nil)
        }

        @Test("save() with invalid weight does nothing")
        func saveInvalidWeight() async {
            let sut = NewMeasurementViewModel(interactor: spy, onSaved: {})
            sut.weightText = ""
            await sut.save()
            #expect(spy.saveMeasurementWasCalled == false)
        }

        @Test("save() updates an existing measurement when editing")
        func saveUpdatesExisting() async {
            let existing = BodyMeasurement(weightKg: 70, heightCm: 170, biologicalSex: .male)
            let sut = NewMeasurementViewModel(interactor: spy, editing: existing, onSaved: {})
            sut.weightText = "72"
            await sut.save()
            #expect(spy.updateMeasurementWasCalled == true)
            #expect(spy.saveMeasurementWasCalled == false)
            #expect(existing.weightKg == 72)
        }

        @Test("save() sets errorMessage on failure")
        func saveFailure() async {
            spy.shouldThrowError = true
            spy.errorToThrow = ProgressError.saveFailed
            let sut = NewMeasurementViewModel(interactor: spy, onSaved: {})
            sut.weightText = "80"
            await sut.save()
            #expect(sut.errorMessage == ProgressError.saveFailed.errorDescription)
        }

        @Test("duplicateMeasurement finds a measurement in the same calendar week")
        func duplicateMeasurementSameWeek() {
            let calendar = Calendar.current
            let today = Date.now
            let existing = BodyMeasurement(date: today, weightKg: 70, heightCm: 170, biologicalSex: .male)
            let sut = NewMeasurementViewModel(interactor: spy, existingMeasurements: [existing], onSaved: {})
            sut.date = today
            #expect(sut.duplicateMeasurement?.id == existing.id)

            let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: today)!
            sut.date = nextWeek
            #expect(sut.duplicateMeasurement == nil)
        }

        @Test("duplicateMeasurement excludes the measurement being edited")
        func duplicateMeasurementExcludesEditing() {
            let today = Date.now
            let editing = BodyMeasurement(date: today, weightKg: 70, heightCm: 170, biologicalSex: .male)
            let sut = NewMeasurementViewModel(interactor: spy, existingMeasurements: [editing], editing: editing, onSaved: {})
            sut.date = today
            #expect(sut.duplicateMeasurement == nil)
        }

        @Test("duplicateMeasurement flags a different measurement when editing moves into its week")
        func duplicateMeasurementFlagsOtherOnEdit() {
            let calendar = Calendar.current
            let today = Date.now
            let other = BodyMeasurement(date: today, weightKg: 70, heightCm: 170, biologicalSex: .male)
            let editing = BodyMeasurement(
                date: calendar.date(byAdding: .weekOfYear, value: -1, to: today)!,
                weightKg: 72,
                heightCm: 170,
                biologicalSex: .male
            )
            let sut = NewMeasurementViewModel(interactor: spy, existingMeasurements: [other, editing], editing: editing, onSaved: {})
            sut.date = today
            #expect(sut.duplicateMeasurement?.id == other.id)
        }

        @Test("save(replacing:) deletes the duplicate before saving")
        func saveReplacingDeletesDuplicate() async {
            let duplicate = BodyMeasurement(weightKg: 71, heightCm: 170, biologicalSex: .male)
            let sut = NewMeasurementViewModel(interactor: spy, onSaved: {})
            sut.weightText = "80"
            await sut.save(replacing: duplicate)
            #expect(spy.deleteMeasurementWasCalled == true)
            #expect(spy.lastDeletedMeasurement?.id == duplicate.id)
            #expect(spy.saveMeasurementWasCalled == true)
        }
    }
}

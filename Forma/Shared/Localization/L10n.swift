//
//  L10n.swift
//  Forma
//
//  Created by Armando Cáceres on 29/6/26.
//

import Foundation

enum L10n {
    
    // MARK: - Common (Localizable.xcstrings)
    
    enum Common {
        static let ok      = String(localized: "OK")
        static let cancel  = String(localized: "Cancel")
        static let done    = String(localized: "Done")
        static let save    = String(localized: "Save")
        static let delete  = String(localized: "Delete")
        static let loading = String(localized: "Loading")
        static let retry   = String(localized: "Retry")
    }
    
    // MARK: - Error (Localizable.xcstrings)
    
    enum Error {
        nonisolated static let generic = String(localized: "Something went wrong")
    }
    
    // MARK: - Tabs (Localizable.xcstrings)
    
    enum Tab {
        static let today     = String(localized: "Today")
        static let training  = String(localized: "Training")
        static let nutrition = String(localized: "Nutrition")
        static let progress  = String(localized: "Progress")
    }
    
    // MARK: - Dashboard (Localizable.xcstrings)
    
    enum Dashboard {
        static let goodMorning   = String(localized: "Good morning")
        static let goodAfternoon = String(localized: "Good afternoon")
        static let goodEvening   = String(localized: "Good evening")
    }
    
    // MARK: - Training (TrainingLocalizable.xcstrings)
    
    enum Training {
        
        enum Session {
            static let start           = String(localized: .TrainingLocalizable.sessionStart)
            static let finish          = String(localized: .TrainingLocalizable.sessionFinish)
            static let restTimer       = String(localized: .TrainingLocalizable.sessionRestTimer)
            static let invalidSetInput = String(localized: .TrainingLocalizable.sessionInvalidInput)
        }
        
        enum Error {
            nonisolated static let loadFailed      = String(localized: .TrainingLocalizable.errorLoadFailed)
            nonisolated static let saveFailed      = String(localized: .TrainingLocalizable.errorSaveFailed)
            nonisolated static let deleteFailed    = String(localized: .TrainingLocalizable.errorDeleteFailed)
            nonisolated static let setActiveFailed = String(localized: .TrainingLocalizable.errorSetActiveFailed)
            nonisolated static let sessionNotFound = String(localized: .TrainingLocalizable.errorSessionNotFound)
            nonisolated static let logSetFailed    = String(localized: .TrainingLocalizable.errorLogSetFailed)
            nonisolated static let finishFailed    = String(localized: .TrainingLocalizable.errorFinishFailed)
        }
    }
    
    // MARK: - Nutrition (NutritionLocalizable.xcstrings + Localizable.xcstrings)
    
    enum Nutrition {
        
        enum Meal {
            static let breakfast   = String(localized: "Breakfast")
            static let lunch       = String(localized: "Lunch")
            static let dinner      = String(localized: "Dinner")
            static let snack       = String(localized: "Snack")
            static let postWorkout = String(localized: "Post-workout")
        }
        
        enum Error {
            nonisolated static let loadFailed   = String(localized: .NutritionLocalizable.errorLoadFailed)
            nonisolated static let saveFailed   = String(localized: .NutritionLocalizable.errorSaveFailed)
            nonisolated static let deleteFailed = String(localized: .NutritionLocalizable.errorDeleteFailed)
        }
    }
    
    // MARK: - Progress (ProgressLocalizable.xcstrings)
    
    enum Progress {
        
        enum Error {
            nonisolated static let loadFailed   = String(localized: .ProgressLocalizable.errorLoadFailed)
            nonisolated static let saveFailed   = String(localized: .ProgressLocalizable.errorSaveFailed)
            nonisolated static let deleteFailed = String(localized: .ProgressLocalizable.errorDeleteFailed)
        }
    }
    
    // MARK: - Settings (SettingsLocalizable.xcstrings)
    
    enum Settings {
        
        enum ICloud {
            static let syncing                = String(localized: .SettingsLocalizable.icloudSyncing)
            static let noAccount              = String(localized: .SettingsLocalizable.icloudNoAccount)
            static let restricted             = String(localized: .SettingsLocalizable.icloudRestricted)
            static let temporarilyUnavailable = String(localized: .SettingsLocalizable.icloudTemporarilyUnavailable)
            static let checking               = String(localized: .SettingsLocalizable.icloudChecking)
            static let unknown                = String(localized: .SettingsLocalizable.icloudUnknown)
        }
        
        enum Error {
            nonisolated static let loadFailed   = String(localized: .SettingsLocalizable.errorLoadFailed)
            nonisolated static let saveFailed   = String(localized: .SettingsLocalizable.errorSaveFailed)
            nonisolated static let exportFailed = String(localized: .SettingsLocalizable.errorExportFailed)
        }
    }
    
    // MARK: - Domain: WorkoutSession (Localizable.xcstrings)
    
    enum WorkoutSession {
        static let planned   = String(localized: "Planned")
        static let freeStyle = String(localized: "Free style")
        static let cardio    = String(localized: "Cardio")
        static let mobility  = String(localized: "Mobility")
    }
    
    // MARK: - Domain: Weekday (Localizable.xcstrings)
    
    enum Weekday {
        static let monday    = String(localized: "Monday")
        static let tuesday   = String(localized: "Tuesday")
        static let wednesday = String(localized: "Wednesday")
        static let thursday  = String(localized: "Thursday")
        static let friday    = String(localized: "Friday")
        static let saturday  = String(localized: "Saturday")
        static let sunday    = String(localized: "Sunday")
        static let monShort  = String(localized: "Mon")
        static let tueShort  = String(localized: "Tue")
        static let wedShort  = String(localized: "Wed")
        static let thuShort  = String(localized: "Thu")
        static let friShort  = String(localized: "Fri")
        static let satShort  = String(localized: "Sat")
        static let sunShort  = String(localized: "Sun")
    }
    
    // MARK: - Domain: BiologicalSex (Localizable.xcstrings)
    
    enum BiologicalSex {
        static let male   = String(localized: "Male")
        static let female = String(localized: "Female")
    }
    
    // MARK: - Domain: ActivityLevel (Localizable.xcstrings)
    
    enum ActivityLevel {
        static let sedentary        = String(localized: "Sedentary")
        static let lightlyActive    = String(localized: "Lightly active")
        static let moderatelyActive = String(localized: "Moderately active")
        static let veryActive       = String(localized: "Very active")
        static let extraActive      = String(localized: "Extra active")
        
        enum Description {
            static let sedentary        = String(localized: "Little or no exercise")
            static let lightlyActive    = String(localized: "Light exercise 1–3 days/week")
            static let moderatelyActive = String(localized: "Moderate exercise 3–5 days/week")
            static let veryActive       = String(localized: "Hard exercise 6–7 days/week")
            static let extraActive      = String(localized: "Very hard exercise or physical job")
        }
    }
    
    // MARK: - Domain: MacroType (Localizable.xcstrings)
    
    enum MacroType {
        static let protein = String(localized: "Protein")
        static let carbs   = String(localized: "Carbs")
        static let fat     = String(localized: "Fat")
        
        enum Abbreviation {
            static let protein = String(localized: "Protein abbreviation")
            static let carbs   = String(localized: "Carbs abbreviation")
            static let fat     = String(localized: "Fat abbreviation")
        }
    }
}

//
//  SettingsView.swift
//  Forma
//
//  Created by Armando Cáceres on 27/4/26.
//

import SwiftUI
import SwiftData
import CloudKit

struct SettingsView: View {

    // MARK: - Private Properties

    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - States

    @State private var viewModel: SettingsViewModel
    @State private var showingEditProfile = false
    #if DEBUG
    @State private var showingLoadSampleDataAlert = false
    @State private var showingClearDataAlert = false
    #endif

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    @AppStorage("com.armando.forma.dailyStepsGoal") private var dailyStepsGoal: Int = 10_000
    @AppStorage("com.armando.forma.dailyExerciseGoal") private var dailyExerciseGoal: Int = 30
    @AppStorage("com.armando.forma.exportWorkoutsToHealth") private var exportWorkoutsToHealth: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initializers
    
    init(
        userProfileRepository: UserProfileRepositoryProtocol,
        healthKitService: HealthKitServiceProtocol
    ) {
        self.userProfileRepository = userProfileRepository
        _viewModel = State(initialValue: SettingsViewModel(healthKitService: healthKitService))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                profileSection
                healthSection
                activityGoalsSection
                syncSection
                exportSection
                aboutSection
                #if DEBUG
                developerSection
                #endif
            }
            .navigationTitle(String(localized: "Settings"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .task { await viewModel.load(userProfileRepository: userProfileRepository) }
            .sheet(isPresented: $showingEditProfile, onDismiss: {
                Task { await viewModel.load(userProfileRepository: userProfileRepository) }
            }) {
                if let profile = viewModel.profile {
                    EditProfileView(profile: profile, repository: userProfileRepository)
                }
            }
            #if DEBUG
            .alert(String(localized: "Load sample data?"), isPresented: $showingLoadSampleDataAlert) {
                Button(String(localized: "Load"), role: .destructive) {
                    PreviewSeedData.insert(into: modelContext)
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "This will add sample data on top of existing records."))
            }
            .alert(String(localized: "Clear all data?"), isPresented: $showingClearDataAlert) {
                Button(String(localized: "Clear"), role: .destructive) {
                    clearAllData()
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "This will permanently delete all data from this device."))
            }
            #endif
        }
    }
    
    // MARK: - Private Views
    
    private var profileSection: some View {
        Section(String(localized: "Profile")) {
            if let profile = viewModel.profile {
                Button {
                    showingEditProfile = true
                } label: {
                    HStack(spacing: DS.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(.accent.opacity(0.15))
                                .frame(width: 52, height: 52)
                            Text(verbatim: profile.name.prefix(1).uppercased())
                                .font(.title2.bold())
                                .foregroundStyle(.accent)
                        }
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Text(verbatim: profile.name)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.textPrimary)
                            Text(verbatim: "\(profile.age) \(String(localized: "years")) · \(Int(profile.heightCm)) cm · \(profile.biologicalSex.localizedName)")
                                .font(.caption)
                                .foregroundStyle(.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.textTertiary)
                    }
                    .padding(.vertical, DS.Spacing.xs)
                }
                .buttonStyle(.plain)
                
                LabeledContent(String(localized: "Activity level"), value: profile.activityLevel.localizedName)
                LabeledContent(String(localized: "Weight unit"), value: profile.weightUnit.localizedName)
            } else {
                Text(String(localized: "No profile found"))
                    .foregroundStyle(.textSecondary)
            }
        }
    }
    
    @ViewBuilder
    private var healthSection: some View {
        Section(String(localized: "Health & Activity")) {
            if viewModel.isHealthKitAvailable {
                HStack {
                    Label(String(localized: "Apple Health"), systemImage: "heart.fill")
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    if viewModel.isHealthKitAuthorized {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.success)
                    } else if viewModel.isRequestingHealthKit {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Button(String(localized: "Request permissions")) {
                            Task { await viewModel.requestHealthKitAccess() }
                        }
                        .font(.subheadline)
                    }
                }
                if let error = viewModel.healthKitError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.error)
                }
                Text(String(localized: "Open Health app to manage permissions"))
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            } else {
                Label(
                    String(localized: "Health not available on this device"),
                    systemImage: "heart.slash"
                )
                .foregroundStyle(.textSecondary)
            }
        }
    }
    
    @ViewBuilder
    private var activityGoalsSection: some View {
        if viewModel.isHealthKitAvailable {
            Section(String(localized: "Activity Goals")) {
                Stepper(value: $dailyStepsGoal, in: 1_000...50_000, step: 1_000) {
                    HStack {
                        Label(String(localized: "Daily steps"), systemImage: "shoeprints.fill")
                        Spacer()
                        Text(verbatim: dailyStepsGoal.formatted())
                            .foregroundStyle(.textSecondary)
                            .monospacedDigit()
                    }
                }
                Stepper(value: $dailyExerciseGoal, in: 15...120, step: 15) {
                    HStack {
                        Label(String(localized: "Daily exercise"), systemImage: "figure.run")
                        Spacer()
                        Text(verbatim: "\(dailyExerciseGoal)m")
                            .foregroundStyle(.textSecondary)
                            .monospacedDigit()
                    }
                }
                Toggle(isOn: $exportWorkoutsToHealth) {
                    Label(String(localized: "Export workouts to Health"), systemImage: "heart.fill")
                }
            }
        }
    }

    private var syncSection: some View {
        Section(String(localized: "iCloud Sync")) {
            HStack {
                Label {
                    Text(viewModel.cloudKitStatusText)
                } icon: {
                    Image(systemName: viewModel.cloudKitStatusIconName)
                        .foregroundStyle(viewModel.cloudKitStatusColor)
                }
                
                Spacer()
                
                if viewModel.cloudKitStatus == .couldNotDetermine {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            if viewModel.cloudKitStatus == .noAccount {
                Text(String(localized: "Sign in to iCloud in Settings to sync your data across devices."))
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }
        }
    }
    
    @ViewBuilder
    private var exportSection: some View {
        Section(String(localized: "Data")) {
            if let url = viewModel.exportFileURL {
                ShareLink(
                    item: url,
                    preview: SharePreview(
                        String(localized: "Forma profile export"),
                        image: Image(systemName: "person.crop.circle")
                    )
                ) {
                    Label(
                        String(localized: "Export profile data"),
                        systemImage: "square.and.arrow.up"
                    )
                }
            }
            if let error = viewModel.exportError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.error)
            }
        }
    }
    
    private var aboutSection: some View {
        Section(String(localized: "About")) {
            LabeledContent(String(localized: "Version"), value: viewModel.appVersion)
        }
    }

    // MARK: - Private Functions

    #if DEBUG
    private func clearAllData() {
        try? modelContext.delete(model: MealLog.self)
        try? modelContext.delete(model: DailyNutritionLog.self)
        try? modelContext.delete(model: MealOptionItem.self)
        try? modelContext.delete(model: MealOption.self)
        try? modelContext.delete(model: Meal.self)
        try? modelContext.delete(model: NutritionPlan.self)
        try? modelContext.delete(model: FoodItem.self)
        try? modelContext.delete(model: LoggedSet.self)
        try? modelContext.delete(model: WorkoutSession.self)
        try? modelContext.delete(model: MuscleVolumeTarget.self)
        try? modelContext.delete(model: PlannedExercise.self)
        try? modelContext.delete(model: WorkoutDay.self)
        try? modelContext.delete(model: Mesocycle.self)
        try? modelContext.delete(model: Exercise.self)
        try? modelContext.delete(model: BodyMeasurement.self)
        try? modelContext.delete(model: ProgressPhoto.self)
        try? modelContext.delete(model: UserProfile.self)
    }
    #endif

    #if DEBUG
    private var developerSection: some View {
        Section("Developer") {
            Button {
                showingLoadSampleDataAlert = true
            } label: {
                Label("Load sample data", systemImage: "sparkles")
            }
            Button(role: .destructive) {
                showingClearDataAlert = true
            } label: {
                Label("Clear all data", systemImage: "trash")
            }
        }
    }
    #endif
}

// MARK: - Previews

#Preview(traits: .previewContainer(.withData)) {
    @Previewable @Environment(AppContainer.self) var container
    SettingsView(
        userProfileRepository: container.userProfileRepository,
        healthKitService: container.healthKitService
    )
}

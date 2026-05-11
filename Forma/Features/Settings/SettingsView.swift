//
//  SettingsView.swift
//  Forma
//
//  Created by Armando Cáceres on 27/4/26.
//

import SwiftUI
import CloudKit

struct SettingsView: View {
    
    // MARK: - Private Properties

    private let userProfileRepository: UserProfileRepositoryProtocol

    // MARK: - States

    @State private var viewModel: SettingsViewModel
    @State private var showingEditProfile = false
    
    // MARK: - Environment
    
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
                syncSection
                exportSection
                aboutSection
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
    
    private var syncSection: some View {
        Section(String(localized: "iCloud Sync")) {
            HStack {
                Label {
                    Text(viewModel.cloudKitStatusText)
                } icon: {
                    Image(systemName: viewModel.cloudKitStatusIconName)
                        .foregroundStyle(viewModel.cloudKitIsHealthy ? Color.success : Color.error)
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
        }
    }
    
    private var aboutSection: some View {
        Section(String(localized: "About")) {
            LabeledContent(String(localized: "Version"), value: viewModel.appVersion)
        }
    }
}

//
//  ProfileSetupView.swift
//  Forma
//
//  Created by Armando Cáceres on 20/4/26.
//

import SwiftUI

struct ProfileSetupView: View {

    // MARK: - States

    @AppStorage("postOnboardingAction") private var postOnboardingAction: AppTab = .today

    // MARK: - Private Properties

    @State private var viewModel: ProfileSetupViewModel

    // MARK: - Initializers

    init(repository: UserProfileRepositoryProtocol, healthKitService: HealthKitServiceProtocol) {
        _viewModel = State(initialValue: ProfileSetupViewModel(
            repository: repository,
            healthKitService: healthKitService
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                stepHeader
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.top, DS.Spacing.lg)

                Group {
                    switch viewModel.currentStep {
                    case 0: nameStep
                    case 1: physicalStep
                    case 2: activityStep
                    case 3: healthKitStep
                    default: nextStepsStep
                    }
                }
                .id(viewModel.currentStep)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }

    // MARK: - Private Views

    private var stepHeader: some View {
        HStack {
            if viewModel.currentStep > 0 {
                Button {
                    viewModel.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .frame(width: DS.Sizing.minTapTarget, height: DS.Sizing.minTapTarget)
                }
            } else {
                Color.clear.frame(width: DS.Sizing.minTapTarget, height: DS.Sizing.minTapTarget)
            }

            Spacer()

            HStack(spacing: DS.Spacing.xs) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index <= viewModel.currentStep ? Color.accent : Color.borderSubtle)
                        .frame(width: 8, height: 8)
                        .animation(.spring(response: 0.3), value: viewModel.currentStep)
                }
            }

            Spacer()

            Color.clear.frame(width: DS.Sizing.minTapTarget, height: DS.Sizing.minTapTarget)
        }
    }

    private var nameStep: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            VStack(spacing: DS.Spacing.sm) {
                Text("Set up your profile")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textPrimary)

                Text("What's your name?")
                    .font(.title3)
                    .foregroundStyle(Color.textSecondary)
            }

            TextField("Your name", text: $viewModel.name)
                .font(.title2)
                .multilineTextAlignment(.center)
                .textContentType(.givenName)
                .submitLabel(.next)
                .onSubmit {
                    if viewModel.canAdvanceFromName { viewModel.advance() }
                }
                .padding(DS.Spacing.md)
                .background(Color.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
                .padding(.horizontal, DS.Spacing.xl)

            Spacer()

            Button {
                viewModel.advance()
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canAdvanceFromName)
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.bottom, DS.Spacing.xxl)
        }
    }

    private var physicalStep: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            Text("Physical stats")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: DS.Spacing.md) {
                physicalRow {
                    DatePicker(
                        String(localized: "Date of birth"),
                        selection: $viewModel.birthDate,
                        in: viewModel.birthDateRange,
                        displayedComponents: .date
                    )
                }

                physicalRow {
                    Stepper(value: $viewModel.heightCm, in: 140...220, step: 1) {
                        HStack {
                            Text("Height")
                                .foregroundStyle(Color.textPrimary)
                            Spacer()
                            Text(verbatim: "\(Int(viewModel.heightCm)) cm")
                                .foregroundStyle(Color.textSecondary)
                                .monospacedDigit()
                        }
                    }
                }

                physicalRow {
                    Picker(String(localized: "Biological sex"), selection: $viewModel.biologicalSex) {
                        ForEach(BiologicalSex.allCases, id: \.self) { sex in
                            Text(sex.localizedName).tag(sex)
                        }
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)

            Spacer()

            Button {
                viewModel.advance()
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.bottom, DS.Spacing.xxl)
        }
    }

    private var activityStep: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            Text("Activity level")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: DS.Spacing.sm) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    activityRow(level)
                }
            }
            .padding(.horizontal, DS.Spacing.lg)

            Spacer()

            Button {
                viewModel.advance()
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.bottom, DS.Spacing.xxl)
        }
    }

    private var healthKitStep: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Color.error)
                .symbolEffect(.pulse)

            VStack(spacing: DS.Spacing.sm) {
                Text("Connect HealthKit")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.textPrimary)

                Text("Sync steps, calories and weight from Apple Health.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, DS.Spacing.xxl)
            }

            Spacer()

            VStack(spacing: DS.Spacing.sm) {
                Button {
                    Task {
                        await viewModel.connectHealthKit()
                        viewModel.advance()
                    }
                } label: {
                    Text("Connect")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)

                Button {
                    viewModel.advance()
                } label: {
                    Text("Skip")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.bottom, DS.Spacing.xxl)
        }
    }

    private var nextStepsStep: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Color.success)
                .symbolEffect(.bounce)

            VStack(spacing: DS.Spacing.sm) {
                Text("You're all set!")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textPrimary)

                Text("What would you like to set up first?")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, DS.Spacing.xxl)
            }

            Spacer()

            VStack(spacing: DS.Spacing.sm) {
                Button {
                    postOnboardingAction = .training
                    Task { await viewModel.save() }
                } label: {
                    Label("Create training plan", systemImage: "figure.strengthtraining.traditional")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .disabled(viewModel.isSaving)

                Button {
                    postOnboardingAction = .nutrition
                    Task { await viewModel.save() }
                } label: {
                    Label("Set up nutrition", systemImage: "fork.knife")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .disabled(viewModel.isSaving)

                Button {
                    Task { await viewModel.save() }
                } label: {
                    Text("Explore the app")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .disabled(viewModel.isSaving)
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.bottom, DS.Spacing.xxl)
        }
    }

    @ViewBuilder
    private func physicalRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(DS.Spacing.md)
            .background(Color.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
    }

    @ViewBuilder
    private func activityRow(_ level: ActivityLevel) -> some View {
        Button {
            viewModel.activityLevel = level
        } label: {
            HStack(spacing: DS.Spacing.md) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(level.localizedName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)

                    Text(level.description)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                if viewModel.activityLevel == level {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accent)
                }
            }
            .padding(DS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.button)
                    .fill(viewModel.activityLevel == level ? Color.accent.opacity(0.1) : Color.backgroundCard)
            )
        }
        .accessibilityLabel(level.localizedName)
        .accessibilityValue(viewModel.activityLevel == level ? String(localized: "Selected") : "")
    }

}

#Preview {
    ProfileSetupView(
        repository: MockUserProfileRepository(),
        healthKitService: MockHealthKitService()
    )
}

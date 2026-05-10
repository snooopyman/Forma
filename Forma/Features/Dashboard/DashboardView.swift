//
//  DashboardView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct DashboardView: View {
    
    // MARK: - States
    
    @State private var viewModel: DashboardViewModel?
    @State private var showingCreateMesocycle = false
    @State private var showingNewMeasurement = false
    @State private var showingSettings = false
    @State private var activeSession: WorkoutSession?
    
    // MARK: - Environment
    
    @Environment(AppContainer.self) private var container
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .task {
            let vm = DashboardViewModel(
                mesocycleRepo: container.mesocycleRepository,
                workoutSessionRepo: container.workoutSessionRepository,
                nutritionRepo: container.nutritionRepository,
                bodyMeasurementRepo: container.bodyMeasurementRepository,
                macroTrackingService: container.macroTrackingService,
                healthKitService: container.healthKitService
            )
            viewModel = vm
            await vm.load()
        }
        .sheet(isPresented: $showingCreateMesocycle) {
            CreateMesocycleView { }
        }
        .sheet(isPresented: $showingNewMeasurement) {
            NewMeasurementView(
                repository: container.bodyMeasurementRepository,
                profileRepository: container.userProfileRepository,
                healthKitService: container.healthKitService
            ) { }
        }
        .fullScreenCover(item: $activeSession) { session in
            if let day = session.workoutDay {
                ActiveSessionView(
                    session: session,
                    workoutDay: day,
                    sessionService: container.workoutSessionService,
                    volumeCalculatorService: container.volumeCalculatorService,
                    restTimerActivityService: container.restTimerActivityService,
                    onDone: { activeSession = nil }
                )
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private func content(vm: DashboardViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.lg) {
                headerSection(vm: vm)
                workoutCard(vm: vm)
                macroCard(vm: vm)
                healthKitCard(vm: vm)
                if vm.showMeasurementReminder {
                    measurementReminderCard
                }
                weeklySummaryCard(vm: vm)
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.xxl)
        }
        .background(.backgroundPrimary)
        .navigationTitle(String(localized: "Today"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(
                userProfileRepository: container.userProfileRepository,
                healthKitService: container.healthKitService
            )
        }
        .refreshable {
            await vm.load()
            await vm.refreshHealthKit()
        }
    }
    
    @ViewBuilder
    private func headerSection(vm: DashboardViewModel) -> some View {
        Text(vm.todayFormatted)
            .font(.subheadline)
            .foregroundStyle(.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, DS.Spacing.sm)
    }
    
    @ViewBuilder
    private func workoutCard(vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Label(String(localized: "Training"), systemImage: "figure.strengthtraining.traditional")
                .font(.headline)
                .foregroundStyle(.textSecondary)
            
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                if let mesocycle = vm.activeMesocycle {
                    Text(mesocycle.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if mesocycle.isPaused {
                        pausedMesocycleContent(mesocycle: mesocycle)
                    } else if let day = vm.todayWorkoutDay {
                        if day.isRestDay {
                            restDayContent(day: day)
                        } else {
                            workoutDayContent(vm: vm, day: day)
                        }
                    } else {
                        noWorkoutDayContent
                    }
                } else {
                    noMesocycleContent
                }
            }
            .padding(DS.Spacing.lg)
            .cardStyle()
        }
    }
    
    @ViewBuilder
    private func pausedMesocycleContent(mesocycle: Mesocycle) -> some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "pause.circle.fill")
                .foregroundStyle(.warning)
                .font(.title2)
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                if let pausedAt = mesocycle.pausedAt {
                    Text(pausedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
            }
            Spacer()
        }
        NavigationLink {
            MesocycleDetailView(
                mesocycle: mesocycle,
                mesocycleRepository: container.mesocycleRepository,
                sessionRepository: container.workoutSessionRepository
            )
        } label: {
            Text(String(localized: "Resume mesocycle"))
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.sm)
                .background(.accent)
                .foregroundStyle(.textOnAccent)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
        }
    }
    
    @ViewBuilder
    private func restDayContent(day: WorkoutDay) -> some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "figure.walk")
                .font(.title2)
                .foregroundStyle(.accent)
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Text(String(localized: "Active rest"))
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    
                    Spacer()
                    
                    Text(String(localized: "Rest day"))
                        .font(.caption2.bold())
                        .foregroundStyle(.accent)
                        .padding(.horizontal, DS.Spacing.sm)
                        .padding(.vertical, DS.Spacing.xs)
                        .background(.accent.opacity(0.15))
                        .clipShape(Capsule())
                }
                if !day.restDayActivity.isEmpty {
                    Text(day.restDayActivity)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func workoutDayContent(vm: DashboardViewModel, day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(day.name)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    Text("\(day.plannedExercises.count) exercises")
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                sessionStatusBadge(vm: vm)
            }
            
            if let inProgress = vm.inProgressSession {
                Button {
                    activeSession = inProgress
                } label: {
                    Text(String(localized: "Continue workout"))
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(.accent)
                        .foregroundStyle(.textOnAccent)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
                }
            } else if !vm.isTodaySessionCompleted {
                NavigationLink {
                    WorkoutDayDetailView(
                        workoutDay: day,
                        mesocycleRepository: container.mesocycleRepository,
                        sessionService: container.workoutSessionService,
                        sessionRepository: container.workoutSessionRepository
                    )
                } label: {
                    Text(String(localized: "Start workout"))
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(.accent)
                        .foregroundStyle(.textOnAccent)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
                }
            }
        }
    }
    
    @ViewBuilder
    private func sessionStatusBadge(vm: DashboardViewModel) -> some View {
        if vm.inProgressSession != nil {
            statusBadge(label: String(localized: "In progress"), color: .warning, icon: "bolt.fill")
        } else if vm.isTodaySessionCompleted {
            statusBadge(label: String(localized: "Completed"), color: .success, icon: "checkmark.circle.fill")
        } else {
            statusBadge(label: String(localized: "Pending"), color: .textSecondary, icon: "circle")
        }
    }
    
    private func statusBadge(label: String, color: Color, icon: String) -> some View {
        HStack(spacing: DS.Spacing.xs) {
            Image(systemName: icon)
            Text(label)
                .font(.caption.bold())
        }
        .foregroundStyle(color)
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, DS.Spacing.xs)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
    
    @ViewBuilder
    private var noWorkoutDayContent: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.title2)
                .foregroundStyle(.textTertiary)
            Text(String(localized: "No training scheduled today"))
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
        }
    }
    
    @ViewBuilder
    private var noMesocycleContent: some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: "dumbbell")
                .font(.title)
                .foregroundStyle(.textTertiary)
            Text(String(localized: "No active mesocycle"))
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
            Button {
                showingCreateMesocycle = true
            } label: {
                Text(String(localized: "Create mesocycle"))
                    .font(.subheadline.bold())
                    .foregroundStyle(.accent)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func macroCard(vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Label(String(localized: "Nutrition"), systemImage: "fork.knife")
                .font(.headline)
                .foregroundStyle(.textSecondary)
            
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                if let summary = vm.macroSummary {
                    HStack(spacing: DS.Spacing.xl) {
                        MacroRingView(
                            proteinCurrent: summary.consumedProteinG,
                            proteinGoal: summary.targetProteinG,
                            carbsCurrent: summary.consumedCarbsG,
                            carbsGoal: summary.targetCarbsG,
                            fatCurrent: summary.consumedFatG,
                            fatGoal: summary.targetFatG
                        )
                        
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            macroRow(
                                label: String(localized: "Calories"),
                                current: summary.consumedCalories,
                                goal: Double(summary.targetCalories),
                                unit: String(localized: "kcal"),
                                color: .accent
                            )
                            macroRow(
                                label: String(localized: "Protein"),
                                current: summary.consumedProteinG,
                                goal: summary.targetProteinG,
                                unit: "g",
                                color: .macroProtein
                            )
                            macroRow(
                                label: String(localized: "Carbs"),
                                current: summary.consumedCarbsG,
                                goal: summary.targetCarbsG,
                                unit: "g",
                                color: .macroCarbs
                            )
                            macroRow(
                                label: String(localized: "Fat"),
                                current: summary.consumedFatG,
                                goal: summary.targetFatG,
                                unit: "g",
                                color: .macroFat
                            )
                        }
                    }
                } else {
                    HStack(spacing: DS.Spacing.sm) {
                        Image(systemName: "fork.knife.circle")
                            .font(.title2)
                            .foregroundStyle(.textTertiary)
                        Text(String(localized: "No active nutrition plan"))
                            .font(.subheadline)
                            .foregroundStyle(.textSecondary)
                        Spacer()
                    }
                }
            }
            .padding(DS.Spacing.lg)
            .cardStyle()
        }
    }
    
    private func macroRow(label: String, current: Double, goal: Double, unit: String, color: Color) -> some View {
        HStack(spacing: DS.Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)
            Spacer()
            Text(verbatim: "\(Int(current))/\(Int(goal))\(unit)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.textPrimary)
        }
    }
    
    @ViewBuilder
    private func healthKitCard(vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Label(String(localized: "Activity"), systemImage: "heart.fill")
                .font(.headline)
                .foregroundStyle(.textSecondary)
            
            Group {
                if !vm.isHealthKitAvailable {
                    Text(String(localized: "Health not available on this device"))
                        .font(.subheadline)
                        .foregroundStyle(.textTertiary)
                } else if !vm.healthKitAuthorized {
                    connectHealthKitButton(vm: vm)
                } else {
                    healthKitMetrics(vm: vm)
                }
            }
            .padding(DS.Spacing.lg)
            .cardStyle()
        }
    }
    
    @ViewBuilder
    private func connectHealthKitButton(vm: DashboardViewModel) -> some View {
        Button {
            Task { await vm.requestHealthKitAccess() }
        } label: {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "heart.circle.fill")
                    .foregroundStyle(.error)
                Text(String(localized: "Connect with Health"))
                    .font(.subheadline.bold())
                    .foregroundStyle(.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.sm)
            .background(.accent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
        }
    }
    
    @ViewBuilder
    private func healthKitMetrics(vm: DashboardViewModel) -> some View {
        HStack {
            healthKitMetric(
                value: vm.todaySteps.formatted(),
                label: String(localized: "Steps"),
                icon: "shoeprints.fill",
                color: .success
            )
            Divider()
            healthKitMetric(
                value: "\(Int(vm.todayActiveCalories))",
                label: String(localized: "Cal"),
                icon: "flame.fill",
                color: .error
            )
            Divider()
            healthKitMetric(
                value: "\(Int(vm.todayExerciseMinutes))m",
                label: String(localized: "Exercise"),
                icon: "figure.run",
                color: .accent
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private func healthKitMetric(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            Text(verbatim: value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var measurementReminderCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Label(String(localized: "Weekly check-in"), systemImage: "ruler")
                .font(.headline)
                .foregroundStyle(.textSecondary)
            
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text(String(localized: "Time to log your weekly measurements"))
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                Button {
                    showingNewMeasurement = true
                } label: {
                    Text(String(localized: "Log measurements"))
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.sm)
                        .background(.accent)
                        .foregroundStyle(.textOnAccent)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button))
                }
            }
            .padding(DS.Spacing.lg)
            .cardStyle()
        }
    }
    
    @ViewBuilder
    private func weeklySummaryCard(vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Label(String(localized: "This week"), systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(.textSecondary)
            
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(verbatim: "\(vm.weeklyCompletedSessions)/\(vm.weeklyPlannedDays)")
                        .font(.title.bold().monospacedDigit())
                        .foregroundStyle(.textPrimary)
                    Text(String(localized: "Sessions completed"))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                weeklyProgressRing(
                    completed: vm.weeklyCompletedSessions,
                    total: vm.weeklyPlannedDays
                )
            }
            .padding(DS.Spacing.lg)
            .cardStyle()
        }
    }
    
    private func weeklyProgressRing(completed: Int, total: Int) -> some View {
        let progress = total > 0 ? Double(completed) / Double(total) : 0
        return ZStack {
            Circle()
                .stroke(.accent.opacity(0.2), lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.6), value: progress)
        }
        .frame(width: 52, height: 52)
    }
}

#Preview(traits: .previewContainer(.withData)) {
    NavigationStack {
        DashboardView()
    }
}

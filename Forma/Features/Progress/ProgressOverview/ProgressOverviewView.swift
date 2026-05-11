//
//  ProgressOverviewView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct ProgressOverviewView: View {

    // MARK: - States

    @State private var viewModel: ProgressOverviewViewModel
    @State private var showNewMeasurement = false
    @State private var editingMeasurement: BodyMeasurement?

    // MARK: - Environment

    @Environment(AppContainer.self) private var container

    // MARK: - Initializers

    init(repository: BodyMeasurementRepositoryProtocol) {
        _viewModel = State(initialValue: ProgressOverviewViewModel(repository: repository))
    }

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.measurements.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.measurements.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle(String(localized: "Progress"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewMeasurement = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(String(localized: "Add measurement"))
            }
        }
        .sheet(isPresented: $showNewMeasurement) {
            NewMeasurementView(
                repository: container.bodyMeasurementRepository,
                profileRepository: container.userProfileRepository,
                healthKitService: container.healthKitService
            ) {
                Task { await viewModel.load() }
            }
        }
        .sheet(item: $editingMeasurement) { measurement in
            NewMeasurementView(
                repository: container.bodyMeasurementRepository,
                profileRepository: container.userProfileRepository,
                healthKitService: container.healthKitService,
                editing: measurement
            ) {
                Task { await viewModel.load() }
            }
        }
        .alert(
            String(localized: "Error"),
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                if let latest = viewModel.latest {
                    latestMetricsCard(latest)
                }
                BodyChartsView(measurements: viewModel.measurements)
                photosCard
                historySection
            }
            .padding(DS.Spacing.lg)
        }
        .background(.backgroundPrimary)
    }

    @ViewBuilder
    private func latestMetricsCard(_ m: BodyMeasurement) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text(String(localized: "Latest check-in"))
                .font(.headline)
                .foregroundStyle(.textPrimary)

            Text(m.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.textSecondary)

            HStack(spacing: 0) {
                metricCell(
                    label: String(localized: "Weight"),
                    value: m.weightKg.formatted(.number.precision(.fractionLength(1))),
                    unit: "kg",
                    delta: viewModel.weightDelta,
                    lowerIsBetter: false
                )

                Divider().frame(height: 48)

                if let bmi = m.bmi {
                    metricCell(
                        label: String(localized: "BMI"),
                        value: bmi.formatted(.number.precision(.fractionLength(1))),
                        unit: "",
                        delta: nil,
                        lowerIsBetter: true
                    )
                    Divider().frame(height: 48)
                }

                if let bf = m.bodyFatPercent {
                    metricCell(
                        label: String(localized: "Body fat"),
                        value: bf.formatted(.number.precision(.fractionLength(1))),
                        unit: "%",
                        delta: viewModel.bodyFatDelta,
                        lowerIsBetter: true
                    )
                } else {
                    VStack(spacing: DS.Spacing.xs) {
                        Text(String(localized: "Body fat"))
                            .font(.caption)
                            .foregroundStyle(.textSecondary)
                        Text(verbatim: "—")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.textTertiary)
                        Text(String(localized: "Add neck & abdomen"))
                            .font(.caption2)
                            .foregroundStyle(.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(DS.Spacing.lg)
        .cardStyle()
    }

    @ViewBuilder
    private func metricCell(
        label: String,
        value: String,
        unit: String,
        delta: Double?,
        lowerIsBetter: Bool
    ) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(verbatim: value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.textPrimary)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
            }

            if let delta, delta != 0 {
                let isPositive = delta > 0
                let isGood = lowerIsBetter ? !isPositive : isPositive
                HStack(spacing: 2) {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                    Text(verbatim: abs(delta).formatted(.number.precision(.fractionLength(1))))
                        .font(.caption2)
                }
                .foregroundStyle(isGood ? Color.success : Color.error)
            } else {
                Text(verbatim: " ").font(.caption2)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var historySection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(String(localized: "History"))
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .padding(.horizontal, DS.Spacing.xs)

            ForEach(groupedHistory, id: \.header) { group in
                Text(group.header)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.textSecondary)
                    .padding(.horizontal, DS.Spacing.xs)
                    .padding(.top, DS.Spacing.xs)

                ForEach(group.items, id: \.current.id) { item in
                    MeasurementRowView(measurement: item.current, previous: item.previous)
                        .contextMenu {
                            Button {
                                editingMeasurement = item.current
                            } label: {
                                Label(String(localized: "Edit"), systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                Task { await viewModel.delete(item.current) }
                            } label: {
                                Label(String(localized: "Delete"), systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    private var photosCard: some View {
        NavigationLink {
            PhotoGalleryView(repository: container.progressPhotoRepository)
        } label: {
            HStack(spacing: DS.Spacing.md) {
                Image(systemName: "photo.stack.fill")
                    .font(.title2)
                    .foregroundStyle(.accent)
                    .frame(width: DS.Sizing.minTapTarget, height: DS.Sizing.minTapTarget)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(String(localized: "Photo gallery"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textPrimary)
                    Text(String(localized: "Track your visual progress"))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(DS.Spacing.lg)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label(String(localized: "No measurements yet"), systemImage: "chart.line.uptrend.xyaxis")
        } description: {
            Text(String(localized: "Log your weight and circumferences weekly to track your body changes"))
        } actions: {
            Button {
                showNewMeasurement = true
            } label: {
                Text(String(localized: "Add measurement"))
                    .primaryButtonLabel()
            }
            .buttonStyle(.glassProminent)
            .tint(.accent)
        }
    }

    // MARK: - Private Functions

    private var groupedHistory: [MeasurementGroup] {
        let all = viewModel.measurements
        var groups: [MeasurementGroup] = []
        var currentHeader = ""
        var currentItems: [MeasurementGroup.Item] = []

        for (i, m) in all.enumerated() {
            let header = m.date.formatted(.dateTime.month(.wide).year())
            let previous = i + 1 < all.count ? all[i + 1] : nil

            if header != currentHeader {
                if !currentItems.isEmpty {
                    groups.append(MeasurementGroup(header: currentHeader, items: currentItems))
                }
                currentHeader = header
                currentItems = []
            }
            currentItems.append(MeasurementGroup.Item(current: m, previous: previous))
        }
        if !currentItems.isEmpty {
            groups.append(MeasurementGroup(header: currentHeader, items: currentItems))
        }
        return groups
    }
}

// MARK: - MeasurementGroup

private struct MeasurementGroup {
    struct Item {
        let current: BodyMeasurement
        let previous: BodyMeasurement?
    }
    let header: String
    let items: [Item]
}

// MARK: - MeasurementRowView

private struct MeasurementRowView: View {

    let measurement: BodyMeasurement
    let previous: BodyMeasurement?

    // MARK: - Computed Properties

    private var weightDelta: Double? {
        guard let prev = previous else { return nil }
        let delta = measurement.weightKg - prev.weightKg
        return abs(delta) > 0.05 ? delta : nil
    }

    private var circumferenceDeltas: [(label: String, delta: Double)] {
        guard let prev = previous else { return [] }
        let pairs: [(String, Double?, Double?)] = [
            (String(localized: "Waist"),   measurement.waistCm,   prev.waistCm),
            (String(localized: "Abdomen"), measurement.abdomenCm, prev.abdomenCm),
            (String(localized: "Arm"),     measurement.armCm,     prev.armCm),
            (String(localized: "Thigh"),   measurement.thighCm,   prev.thighCm),
            (String(localized: "Pelvis"),  measurement.pelvisCm,  prev.pelvisCm),
        ]
        return pairs.compactMap { label, current, prevVal in
            guard let c = current, let p = prevVal, abs(c - p) > 0.05 else { return nil }
            return (label: label, delta: c - p)
        }
        .prefix(3)
        .map { $0 }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(measurement.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textPrimary)

                    if let bf = measurement.bodyFatPercent {
                        Text(verbatim: "\(bf.formatted(.number.precision(.fractionLength(1))))% \(String(localized: "fat"))")
                            .font(.caption)
                            .foregroundStyle(.macroFat)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                    Text(verbatim: "\(measurement.weightKg.formatted(.number.precision(.fractionLength(1)))) kg")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textPrimary)

                    if let delta = weightDelta {
                        HStack(spacing: 2) {
                            Image(systemName: delta > 0 ? "arrow.up" : "arrow.down")
                                .font(.caption2)
                            Text(verbatim: abs(delta).formatted(.number.precision(.fractionLength(1))))
                                .font(.caption2)
                        }
                        .foregroundStyle(.textSecondary)
                    }
                }
            }

            if !circumferenceDeltas.isEmpty {
                HStack(spacing: DS.Spacing.md) {
                    ForEach(circumferenceDeltas, id: \.label) { item in
                        HStack(spacing: 2) {
                            Text(item.label)
                                .font(.caption2)
                                .foregroundStyle(.textSecondary)
                            Text(verbatim: (item.delta > 0 ? "+" : "") + item.delta.formatted(.number.precision(.fractionLength(1))))
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(item.delta < 0 ? Color.success : Color.warning)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }
}

#Preview(traits: .previewContainer()) {
    @Previewable @Environment(AppContainer.self) var container
    NavigationStack {
        ProgressOverviewView(repository: container.bodyMeasurementRepository)
    }
}

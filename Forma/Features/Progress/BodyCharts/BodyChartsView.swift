//
//  BodyChartsView.swift
//  Forma
//
//  Created by Armando Cáceres on 5/4/26.
//

import SwiftUI
import Charts

struct BodyChartsView: View {

    // MARK: - Properties

    let measurements: [BodyMeasurement]

    // MARK: - States

    @State private var selectedChart: ChartType = .weight
    @State private var timeRange: TimeRange = .threeMonths
    @State private var selectedCircumference: CircumferenceType = .waist

    // MARK: - Computed Properties

    private var filteredMeasurements: [BodyMeasurement] {
        guard let months = timeRange.months else { return measurements }
        let cutoff = Calendar.current.date(byAdding: .month, value: -months, to: .now) ?? .now
        return measurements.filter { $0.date >= cutoff }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Picker(String(localized: "Chart"), selection: $selectedChart) {
                ForEach(ChartType.allCases) { type in
                    Text(type.label).tag(type)
                }
            }
            .pickerStyle(.segmented)

            Picker(String(localized: "Time range"), selection: $timeRange) {
                ForEach(TimeRange.allCases) { range in
                    Text(range.label).tag(range)
                }
            }
            .pickerStyle(.segmented)

            if selectedChart == .circumferences {
                Picker(String(localized: "Circumference"), selection: $selectedCircumference) {
                    ForEach(CircumferenceType.allCases) { type in
                        Text(type.label).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            switch selectedChart {
            case .weight:
                weightChart
            case .bodyFat:
                bodyFatChart
            case .circumferences:
                circumferenceChart
            }
        }
        .padding(DS.Spacing.lg)
        .cardStyle()
    }

    // MARK: - Private Views

    @ViewBuilder
    private var weightChart: some View {
        let sorted = filteredMeasurements.sorted { $0.date < $1.date }
        if sorted.isEmpty {
            emptyChartPlaceholder
        } else {
            Chart(sorted, id: \.id) { m in
                LineMark(
                    x: .value(String(localized: "Date"), m.date, unit: .day),
                    y: .value(String(localized: "Weight"), m.weightKg)
                )
                .foregroundStyle(Color.accent)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value(String(localized: "Date"), m.date, unit: .day),
                    y: .value(String(localized: "Weight"), m.weightKg)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accent.opacity(0.2), Color.accent.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value(String(localized: "Date"), m.date, unit: .day),
                    y: .value(String(localized: "Weight"), m.weightKg)
                )
                .foregroundStyle(Color.accent)
                .symbolSize(30)
            }
            .chartYScale(domain: weightDomain(sorted))
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .foregroundStyle(Color.textSecondary)
                    AxisGridLine().foregroundStyle(Color.borderSubtle)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { mark in
                    AxisValueLabel {
                        if let value = mark.as(Double.self) {
                            Text(verbatim: value.formatted(.number.precision(.fractionLength(1))))
                                .font(.caption2)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    AxisGridLine().foregroundStyle(Color.borderSubtle)
                }
            }
            .frame(height: 160)
        }
    }

    @ViewBuilder
    private var bodyFatChart: some View {
        let sorted = filteredMeasurements.sorted { $0.date < $1.date }.filter { $0.bodyFatPercent != nil }
        if sorted.isEmpty {
            emptyChartPlaceholder
        } else {
            Chart(sorted, id: \.id) { m in
                if let bf = m.bodyFatPercent {
                    LineMark(
                        x: .value(String(localized: "Date"), m.date, unit: .day),
                        y: .value(String(localized: "Body fat %"), bf)
                    )
                    .foregroundStyle(Color.macroFat)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value(String(localized: "Date"), m.date, unit: .day),
                        y: .value(String(localized: "Body fat %"), bf)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.macroFat.opacity(0.2), Color.macroFat.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value(String(localized: "Date"), m.date, unit: .day),
                        y: .value(String(localized: "Body fat %"), bf)
                    )
                    .foregroundStyle(Color.macroFat)
                    .symbolSize(30)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .foregroundStyle(Color.textSecondary)
                    AxisGridLine().foregroundStyle(Color.borderSubtle)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { mark in
                    AxisValueLabel {
                        if let value = mark.as(Double.self) {
                            Text(verbatim: "\(value.formatted(.number.precision(.fractionLength(1))))%")
                                .font(.caption2)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    AxisGridLine().foregroundStyle(Color.borderSubtle)
                }
            }
            .frame(height: 160)
        }
    }

    @ViewBuilder
    private var circumferenceChart: some View {
        let sorted = filteredMeasurements
            .sorted { $0.date < $1.date }
            .filter { selectedCircumference.value(from: $0) != nil }
        if sorted.isEmpty {
            emptyChartPlaceholder
        } else {
            Chart(sorted, id: \.id) { m in
                if let value = selectedCircumference.value(from: m) {
                    LineMark(
                        x: .value(String(localized: "Date"), m.date, unit: .day),
                        y: .value("cm", value)
                    )
                    .foregroundStyle(selectedCircumference.color)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value(String(localized: "Date"), m.date, unit: .day),
                        y: .value("cm", value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [selectedCircumference.color.opacity(0.2), selectedCircumference.color.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value(String(localized: "Date"), m.date, unit: .day),
                        y: .value("cm", value)
                    )
                    .foregroundStyle(selectedCircumference.color)
                    .symbolSize(30)
                }
            }
            .chartYScale(domain: circumferenceDomain(sorted))
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .foregroundStyle(Color.textSecondary)
                    AxisGridLine().foregroundStyle(Color.borderSubtle)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { mark in
                    AxisValueLabel {
                        if let value = mark.as(Double.self) {
                            Text(verbatim: "\(value.formatted(.number.precision(.fractionLength(0))))cm")
                                .font(.caption2)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    AxisGridLine().foregroundStyle(Color.borderSubtle)
                }
            }
            .frame(height: 160)
        }
    }

    @ViewBuilder
    private var emptyChartPlaceholder: some View {
        Text(String(localized: "Not enough data yet"))
            .font(.subheadline)
            .foregroundStyle(.textTertiary)
            .frame(maxWidth: .infinity, minHeight: 120)
            .multilineTextAlignment(.center)
    }

    // MARK: - Private Functions

    private func weightDomain(_ sorted: [BodyMeasurement]) -> ClosedRange<Double> {
        let weights = sorted.map { $0.weightKg }
        let min = (weights.min() ?? 0) - 2
        let max = (weights.max() ?? 100) + 2
        return min...max
    }

    private func circumferenceDomain(_ sorted: [BodyMeasurement]) -> ClosedRange<Double> {
        let values = sorted.compactMap { selectedCircumference.value(from: $0) }
        let min = (values.min() ?? 0) - 2
        let max = (values.max() ?? 100) + 2
        return min...max
    }
}

// MARK: - ChartType

enum ChartType: String, CaseIterable, Identifiable {
    case weight
    case bodyFat
    case circumferences

    var id: String { rawValue }

    var label: String {
        switch self {
        case .weight:         return String(localized: "Weight")
        case .bodyFat:        return String(localized: "Body fat")
        case .circumferences: return String(localized: "Measurements")
        }
    }
}

// MARK: - TimeRange

enum TimeRange: String, CaseIterable, Identifiable {
    case oneMonth
    case threeMonths
    case sixMonths
    case oneYear
    case all

    var id: String { rawValue }

    var label: String {
        switch self {
        case .oneMonth:    return "1M"
        case .threeMonths: return "3M"
        case .sixMonths:   return "6M"
        case .oneYear:     return "1Y"
        case .all:         return String(localized: "All")
        }
    }

    var months: Int? {
        switch self {
        case .oneMonth:    return 1
        case .threeMonths: return 3
        case .sixMonths:   return 6
        case .oneYear:     return 12
        case .all:         return nil
        }
    }
}

// MARK: - CircumferenceType

enum CircumferenceType: String, CaseIterable, Identifiable {
    case waist
    case abdomen
    case arm
    case thigh
    case pelvis

    var id: String { rawValue }

    var label: String {
        switch self {
        case .waist:   return String(localized: "Waist")
        case .abdomen: return String(localized: "Abdomen")
        case .arm:     return String(localized: "Arm")
        case .thigh:   return String(localized: "Thigh")
        case .pelvis:  return String(localized: "Pelvis")
        }
    }

    var color: Color {
        switch self {
        case .waist:   return .macroCarbs
        case .abdomen: return .error
        case .arm:     return .macroProtein
        case .thigh:   return .macroFat
        case .pelvis:  return .success
        }
    }

    func value(from m: BodyMeasurement) -> Double? {
        switch self {
        case .waist:   return m.waistCm
        case .abdomen: return m.abdomenCm
        case .arm:     return m.armCm
        case .thigh:   return m.thighCm
        case .pelvis:  return m.pelvisCm
        }
    }
}

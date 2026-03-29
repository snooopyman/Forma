//
//  MetricTrendCard.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI
import Charts

struct MetricTrendCard: View {
    let title: String
    let value: String
    let unit: String
    let delta: Double?
    let sparklineData: [Double]

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.xs) {
                Text(verbatim: value)
                    .font(.title2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Color.textPrimary)

                Text(unit)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                if let delta {
                    DeltaBadge(delta: delta)
                }
            }

            if !sparklineData.isEmpty {
                Sparkline(data: sparklineData)
                    .frame(height: DS.Sizing.sparklineHeight)
            }
        }
        .padding(DS.Spacing.lg)
        .cardStyle()
    }
}

private struct DeltaBadge: View {
    let delta: Double

    private var isPositive: Bool { delta >= 0 }
    private var symbol: String { isPositive ? "arrow.up" : "arrow.down" }
    private var color: Color { isPositive ? .success : .error }

    var body: some View {
        Label(String(format: "%.1f", abs(delta)), systemImage: symbol)
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
    }
}

private struct Sparkline: View {
    let data: [Double]

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(Color.accent)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accent.opacity(0.3), Color.accent.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: (data.min() ?? 0)...(data.max() ?? 1))
    }
}

#Preview {
    VStack(spacing: DS.Spacing.md) {
        MetricTrendCard(
            title: "Body weight",
            value: "82.5",
            unit: "kg",
            delta: -0.8,
            sparklineData: [85, 84.2, 83.8, 83.5, 83.1, 82.8, 82.5]
        )
        MetricTrendCard(
            title: "Body fat",
            value: "16.2",
            unit: "%",
            delta: -0.4,
            sparklineData: [18, 17.5, 17.1, 16.8, 16.5, 16.3, 16.2]
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}

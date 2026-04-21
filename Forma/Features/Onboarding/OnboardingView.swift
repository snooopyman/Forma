//
//  OnboardingView.swift
//  Forma
//
//  Created by Armando Cáceres on 20/4/26.
//

import SwiftUI

struct OnboardingView: View {

    // MARK: - States

    @AppStorage("tourCompleted") private var tourCompleted = false
    @State private var currentPage = 0

    // MARK: - Private Properties

    private let pages: [TourPage] = [
        TourPage(
            symbol: "figure.arms.open",
            title: "Welcome to Forma",
            subtitle: "Training, nutrition and progress — all in one place.",
            color: .accent
        ),
        TourPage(
            symbol: "figure.strengthtraining.traditional",
            title: "Train with structure",
            subtitle: "Mesocycles, sets, and rest timers with Live Activity.",
            color: .accent
        ),
        TourPage(
            symbol: "fork.knife",
            title: "Fuel your training",
            subtitle: "Track macros with a personalised nutrition plan.",
            color: Color.macroProtein
        ),
        TourPage(
            symbol: "chart.line.uptrend.xyaxis",
            title: "Measure your progress",
            subtitle: "Photos, measurements, and body metrics week by week.",
            color: .success
        )
    ]

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    tourPage(pages[index], isLast: index == pages.count - 1)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .background(.backgroundPrimary)
            .ignoresSafeArea()

            if currentPage < pages.count - 1 {
                Button("Skip") {
                    tourCompleted = true
                }
                .buttonStyle(.glass)
                .padding(DS.Spacing.lg)
            }
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private func tourPage(_ page: TourPage, isLast: Bool) -> some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            Image(systemName: page.symbol)
                .font(.system(size: 80, weight: .light))
                .foregroundStyle(page.color)
                .symbolEffect(.pulse)

            VStack(spacing: DS.Spacing.sm) {
                Text(page.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textPrimary)

                Text(page.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, DS.Spacing.xxl)
            }

            Spacer()

            if isLast {
                Button {
                    tourCompleted = true
                } label: {
                    Text("Get started")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .padding(.horizontal, DS.Spacing.xl)
            } else {
                Color.clear.frame(height: DS.Sizing.minTapTarget)
            }
        }
        .padding(.bottom, DS.Spacing.xxl)
    }
}

// MARK: - Supporting Types

private struct TourPage {
    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let color: Color
}

#Preview {
    OnboardingView()
}

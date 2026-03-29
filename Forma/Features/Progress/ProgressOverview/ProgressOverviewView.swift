//
//  ProgressOverviewView.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI

struct ProgressOverviewView: View {

    // MARK: - Body

    var body: some View {
        ContentUnavailableView("Progress", systemImage: "chart.line.uptrend.xyaxis")
    }
}

#Preview {
    ProgressOverviewView()
}

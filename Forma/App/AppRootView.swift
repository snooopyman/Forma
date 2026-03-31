//
//  AppRootView.swift
//  Forma
//
//  Created by Armando Cáceres on 30/3/26.
//

import SwiftUI
import SwiftData

struct AppRootView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - States

    @State private var container: AppContainer?

    // MARK: - Body

    var body: some View {
        Group {
            if let container {
                MainTabView()
                    .environment(container)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            guard container == nil else { return }
            container = AppContainer(modelContext: modelContext)
        }
    }
}

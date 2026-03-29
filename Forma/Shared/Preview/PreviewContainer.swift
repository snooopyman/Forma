//
//  PreviewContainer.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftUI
import SwiftData

struct PreviewContainer: PreviewModifier {

    enum DataContent {
        case empty
        case withData
    }

    static var dataContent: DataContent = .empty

    static func makeSharedContext() async throws -> ModelContainer {
        let schema = Schema(FormaSchema.models)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        
        if case .withData = dataContent {
            PreviewSeedData.insert(into: container.mainContext)
        }
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
            .environment(AppContainer(modelContext: context.mainContext))
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor
    static func previewContainer(_ dataContent: PreviewContainer.DataContent = .withData) -> Self {
        PreviewContainer.dataContent = dataContent
        return .modifier(PreviewContainer())
    }
}

//
//  FormaModelContainer.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import SwiftData
import Foundation
import os

enum FormaModelContainer {

    // MARK: - Properties

    static let appGroupIdentifier = "group.com.armando.forma"
    private static let databaseFilename = "Forma.sqlite"
    private static let cloudKitIdentifier = "iCloud.com.armando.forma"

    // MARK: - Functions

    static func make() throws -> ModelContainer {
        let schema = Schema(FormaSchema.models)
        let configuration = makeConfiguration(for: schema)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    // MARK: - Private Functions

    private static func makeConfiguration(for schema: Schema) -> ModelConfiguration {
        guard let storeURL = appGroupStoreURL() else {
            // Fallback: simulator sin App Group configurado o primer arranque sin entitlements
            Logger.core.warning("App Group no disponible — usando ubicación por defecto")
            return ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .private(cloudKitIdentifier)
            )
        }

        return ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .private(cloudKitIdentifier)
        )
    }

    private static func appGroupStoreURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent(databaseFilename)
    }
}

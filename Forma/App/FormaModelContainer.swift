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
            Logger.core.warning("App Group no disponible — usando ubicación por defecto")
            return ModelConfiguration(
                schema: schema,
                cloudKitDatabase: cloudKitDatabase
            )
        }

        return ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: cloudKitDatabase
        )
    }

    private static var cloudKitDatabase: ModelConfiguration.CloudKitDatabase {
        #if targetEnvironment(simulator)
        .none
        #else
        .private(cloudKitIdentifier)
        #endif
    }

    private static func appGroupStoreURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent(databaseFilename)
    }
}

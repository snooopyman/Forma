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

    static let shared: ModelContainer? = {
        let schema = Schema(FormaSchema.models)
        let configuration = makeConfiguration(for: schema)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            Logger.core.error("ModelContainer failed, attempting store reset: \(error, privacy: .public)")
            return recoverContainer(schema: schema, configuration: configuration)
        }
    }()

    // MARK: - Private Functions

    private static func recoverContainer(schema: Schema, configuration: ModelConfiguration) -> ModelContainer? {
        let url = configuration.url
        let relatedURLs = [
            url,
            url.deletingPathExtension().appendingPathExtension("sqlite-shm"),
            url.deletingPathExtension().appendingPathExtension("sqlite-wal")
        ]
        relatedURLs.forEach { try? FileManager.default.removeItem(at: $0) }
        Logger.core.warning("Deleted corrupt store at \(url.lastPathComponent, privacy: .public) — starting fresh")
        do {
            let freshConfig = makeConfiguration(for: schema)
            return try ModelContainer(for: schema, configurations: [freshConfig])
        } catch {
            Logger.core.error("ModelContainer recovery failed: \(error, privacy: .public)")
            return nil
        }
    }

    private static func makeConfiguration(for schema: Schema) -> ModelConfiguration {
        guard let storeURL = appGroupStoreURL() else {
            Logger.core.warning("App Group not available — using default location")
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

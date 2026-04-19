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

        // Try CloudKit first; fall back to local-only if the entitlement isn't provisioned.
        if let container = makeContainer(schema: schema, useCloudKit: true) {
            return container
        }
        Logger.core.warning("CloudKit unavailable — running in local-only mode")
        return makeContainer(schema: schema, useCloudKit: false)
    }()

    // MARK: - Private Functions

    private static func makeContainer(schema: Schema, useCloudKit: Bool) -> ModelContainer? {
        let configuration = makeConfiguration(for: schema, useCloudKit: useCloudKit)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            Logger.core.error("ModelContainer init failed (cloudKit=\(useCloudKit)): \(error, privacy: .public)")
            if useCloudKit { return nil }
            return recoverContainer(schema: schema)
        }
    }

    private static func recoverContainer(schema: Schema) -> ModelContainer? {
        let configuration = makeConfiguration(for: schema, useCloudKit: false)
        let url = configuration.url
        let relatedURLs = [
            url,
            url.deletingPathExtension().appendingPathExtension("sqlite-shm"),
            url.deletingPathExtension().appendingPathExtension("sqlite-wal")
        ]
        relatedURLs.forEach { try? FileManager.default.removeItem(at: $0) }
        Logger.core.warning("Deleted corrupt store at \(url.lastPathComponent, privacy: .public) — starting fresh")
        do {
            let freshConfig = makeConfiguration(for: schema, useCloudKit: false)
            return try ModelContainer(for: schema, configurations: [freshConfig])
        } catch {
            Logger.core.error("ModelContainer recovery failed: \(error, privacy: .public)")
            return nil
        }
    }

    private static func makeConfiguration(for schema: Schema, useCloudKit: Bool) -> ModelConfiguration {
        let cloudKit: ModelConfiguration.CloudKitDatabase = useCloudKit ? cloudKitDatabase : .none

        guard let storeURL = appGroupStoreURL() else {
            Logger.core.warning("App Group not available — using default location")
            return ModelConfiguration(schema: schema, cloudKitDatabase: cloudKit)
        }

        return ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: cloudKit)
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

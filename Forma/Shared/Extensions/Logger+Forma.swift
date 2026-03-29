//
//  Logger+Forma.swift
//  Forma
//
//  Created by Armando Cáceres on 29/3/26.
//

import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.armando.forma"

    static let core      = Logger(subsystem: subsystem, category: "core")
    static let training  = Logger(subsystem: subsystem, category: "training")
    static let nutrition = Logger(subsystem: subsystem, category: "nutrition")
    static let progress  = Logger(subsystem: subsystem, category: "progress")
    static let healthKit = Logger(subsystem: subsystem, category: "healthkit")
    static let sync      = Logger(subsystem: subsystem, category: "sync")
}

//
//  Bundle+AppVersion.swift
//  Forma
//
//  Created by Armando Cáceres on 28/6/26.
//
import Foundation

extension Bundle {
    static var appVersion: String {
        let version = main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build   = main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

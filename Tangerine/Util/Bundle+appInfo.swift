//
//  Bundle+appInfo.swift
//  Tangerine
//
//  Created by Forest Katsch on 8/19/23.
//

import Foundation

extension Bundle {
    var identifier: String? { info("CFBundleIdentifier") }
    var appBuild: String? { info("CFBundleVersion") }
    var appVersionLong: String? { info("CFBundleShortVersionString") }

    private func info(_ key: String) -> String? {
        infoDictionary?[key] as? String
    }
}

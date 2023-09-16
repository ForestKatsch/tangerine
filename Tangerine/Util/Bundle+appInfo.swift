//
//  Bundle.swift
//  Pensieve
//
//  Created by Forest Katsch on 8/19/23.
//

import Foundation

public extension Bundle {
    var appName: String? { getInfo("CFBundleName") }
    var displayName: String? { getInfo("CFBundleDisplayName") }
    var language: String? { getInfo("CFBundleDevelopmentRegion") }
    var identifier: String? { getInfo("CFBundleIdentifier") }

    var appBuild: String? { getInfo("CFBundleVersion") }
    var appVersionLong: String? { getInfo("CFBundleShortVersionString") }
    // public var appVersionShort: String { getInfo("CFBundleShortVersion") }

    fileprivate func getInfo(_ str: String) -> String? { infoDictionary?[str] as? String }
}

//
//  Formatter.swift
//  Tangerine
//
//  Created by Forest Katsch on 8/19/23.
//

import Foundation

enum Formatter {
    private static let abbreviations = ["%.0f", "%.1fk", "%.1fm"]

    /// 999 → "999", 1234 → "1.2k", 1234567 → "1.2m".
    static func format(intToAbbreviation int: Int?) -> String {
        guard let int else {
            return "-"
        }

        var num = Float(int)
        var index = 0

        while num > 1000 && index < abbreviations.count - 1 {
            index += 1
            num /= 1000
        }

        return String(format: abbreviations[index], num)
    }

    private static let wwwPrefix = try! Regex("^(www[0-9]*\\.)?")

    /// The host without a leading "www.", e.g. "example.com".
    static func format(urlHost url: URL) -> String {
        (url.host() ?? "").replacing(wwwPrefix, with: "")
    }
}

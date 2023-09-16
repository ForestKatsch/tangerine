//
//  Formatter.swift
//  Pensieve
//
//  Created by Forest Katsch on 8/19/23.
//

import Foundation

let prefixes: [String] = ["%.0f", "%.1fk", "%.1fm"]

enum Formatter {
    static func format(intToAbbreviation int: Int?) -> String {
        guard let int else {
            return "-"
        }

        var num = Float(int)
        var index = 0

        while num > 1000 && index < prefixes.count {
            index += 1
            num /= 1000
        }

        return String(format: prefixes[index], num)
    }

    static func format(urlWithoutPrefix url: URL) -> String {
        return url.absoluteString.replacing(try! Regex("^https?://(www[0-9]*\\.)?"), with: "")
    }

    static func format(urlHost url: URL) -> String {
        return (url.host() ?? "").replacing(try! Regex("^(www[0-9]*\\.)?"), with: "")
    }
}

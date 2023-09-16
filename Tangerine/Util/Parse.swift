//
//  Parse.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation

enum Parse {
    static func int(_ string: String) -> Int? {
        Int(string.trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet.letters)))
    }

    // Parses HN's date format.
    static func date(fromSubline string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = .gmt
        return dateFormatter.date(from: string)
    }
}

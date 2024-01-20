//
//  API+parse.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/19/24.
//

import Foundation
import SwiftSoup

extension API {
    func parse(_ document: Document) throws {
        guard let main = try? document.select("#hnmain").first() else {
            throw TangerineError.generic(.cannotParseHtml, context: "#hnmain")
        }

        memorial = (try? main.select("> tbody > tr > td[bgcolor=#000000]").first()) != nil

        print(memorial)
    }
}

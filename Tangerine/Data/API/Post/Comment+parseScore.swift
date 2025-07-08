//
//  Comment+parseScore.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/7/25.
//

import SwiftSoup

extension Comment {
    static func parseScore(fromComment element: Element) throws -> Int? {
        guard let classNames = try? element.classNames() else {
            print("unable to find class names \(element)")
            return nil
        }
        
        // Look for a class matching the pattern cxx, where xx are two hex digits
        if let cxx = classNames.first(where: { $0.count == 3 && $0.hasPrefix("c") && $0.dropFirst().allSatisfy({ $0.isHexDigit }) }) {
            let hex = String(cxx.dropFirst())
            if let value = Int(hex, radix: 16) {
                // Clamp to expected range (0x00 to 0xdd)
                let clamped = min(value, 0xdd)
                // Map 0x00 -> 0, 0x11 -> -1, ..., 0xdd -> -9
                let score = -(clamped / 0x1d)
                return score
            }
        }
        
        print("unable to find score in class names \(classNames)")

        return nil
    }
}

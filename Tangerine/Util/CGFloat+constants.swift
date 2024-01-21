//
//  CGFloat+constants.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation

extension CGFloat {
    static let spacingSmall: CGFloat = 5
    static let spacingMedium: CGFloat = 10
    static let spacingLarge: CGFloat = 20
    static let spacingHuge: CGFloat = 30

    #if os(visionOS)
        static let spacingHorizontal: CGFloat = 20
    #else
        static let spacingHorizontal: CGFloat = 20
    #endif
}

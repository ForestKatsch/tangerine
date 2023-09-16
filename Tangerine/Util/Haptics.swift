//
//  Haptics.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/15/23.
//

import Foundation
import SwiftUI

enum Haptics {
    static func impact() {
        #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }
}

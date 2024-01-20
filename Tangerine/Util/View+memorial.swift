//
//  View+if.swift
//  Pensieve
//
//  Created by Forest Katsch on 8/21/23.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func memorial() -> some View {
        self
        /*
         #if os(macOS) || os(visionOS)
             return self
         #endif
         if API.shared.memorial {
             self
                 .toolbarColorScheme(.dark, for: .navigationBar)
                 .toolbarBackground(
                     Color.black,
                     for: .navigationBar
                 )
                 .toolbarBackground(.visible, for: .navigationBar)
         } else {
             self
         }
          */
    }
}

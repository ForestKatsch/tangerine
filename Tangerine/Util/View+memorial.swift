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
        #if os(iOS)
            if API.shared.memorial {
                self
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(
                        .black,
                        for: .navigationBar
                    )
                    .toolbarBackground(.visible, for: .navigationBar)
            } else {
                self
            }
        #else
            self
        #endif
    }
}

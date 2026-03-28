//
//  TangerineApp.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

@main
struct TangerineApp: App {
    var body: some Scene {
        WindowGroup {
            WindowRoot()
        }
        #if !os(tvOS)
        .windowResizability(.contentSize)
        #endif

        #if os(macOS)
            Settings {
                SettingsScreen()
            }
        #endif
    }
}

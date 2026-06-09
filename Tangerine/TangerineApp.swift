//
//  TangerineApp.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Aquifer
import SwiftUI

@main
struct TangerineApp: App {
    @State private var queryClient = QueryClient(
        options: QueryOptions(staleTime: .seconds(5), refetchOnForeground: true)
    )

    var body: some Scene {
        WindowGroup {
            WindowRoot()
                .queryClient(queryClient)
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

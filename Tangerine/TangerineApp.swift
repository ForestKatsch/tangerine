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
    // A five-second stale time meant almost every tab switch, back-navigation and resume counted as
    // stale and re-fetched. HN's front page doesn't move that fast, and the listing is an
    // `InfiniteQuery`, so a revalidation still reloads page one — just not several times a minute.
    @State private var queryClient = QueryClient(
        options: QueryOptions(staleTime: .seconds(60), refetchOnForeground: true)
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

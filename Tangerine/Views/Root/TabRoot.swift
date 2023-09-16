//
//  TabRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct TabRoot: View {
    enum Screen: Int, Identifiable, CaseIterable {
        var id: Int { rawValue }

        case browse
        case account
        case search

        @ViewBuilder
        var view: some View {
            switch self {
            case .browse:
                ListingTab()
            case .account:
                Text("Account")
            case .search:
                Text("Search")
            }
        }

        var name: LocalizedStringKey {
            switch self {
            case .browse:
                return "Browse"
            case .account:
                return "Account"
            case .search:
                return "Search"
            }
        }

        var systemImage: String {
            switch self {
            case .browse:
                return "doc.richtext"
            case .account:
                return "person.crop.circle"
            case .search:
                return "magnifyingglass"
            }
        }
    }

    var body: some View {
        TabView {
            ForEach(Screen.allCases) { screen in
                screen.view
                    .tag(screen)
                    .tabItem {
                        Label(screen.name, systemImage: screen.systemImage)
                    }
            }
        }
    }
}

#Preview {
    TabRoot()
}

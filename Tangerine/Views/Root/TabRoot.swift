//
//  VisionTabRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct TabRoot: View {
    @State
    var post: Post?

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @ViewBuilder
    var tabs: some View {
        TabView {
            Tab(API.ListingType.news.name, systemImage: API.ListingType.news.systemImage) {
                NavigationStack {
                    ListingScreen(type: API.ListingType.news)
                }
            }
            Tab("explore.label", systemImage: "book.pages") {
                NavigationStack {
                    ExploreScreen(type: .show)
                }
            }
            Tab("settings.label", systemImage: "gear") {
                NavigationStack {
                    SettingsScreen()
                }
            }
        }
    }

    @ViewBuilder
    var columns: some View {
        ListingColumns()
    }

    var body: some View {
        if horizontalSizeClass == .compact {
            tabs
        } else {
            columns
        }
    }
}

#Preview {
    VisionTabRoot()
}

struct ExploreScreen: View {
    @State
    var type: API.ListingType
    
    @ViewBuilder
    var picker: some View {
        Picker("explore.options", selection: $type) {
            ForEach(API.ListingType.allCases.filter { $0 != .news }) { type in
                Label(type.name, systemImage: type.systemImage)
            }
        }
    }
    
    var body: some View {
        ListingScreen(type: type)
            .toolbar {
                ToolbarTitleMenu {
                    picker
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

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

    @State
    var accountOpen = false

    @ViewBuilder
    var toolbar: some View {
        Button("account.label", systemImage: "person.crop.circle") {
            accountOpen.toggle()
        }
        .sheet(isPresented: $accountOpen) {
            NavigationStack {
                AccountScreen()
            }
        }
    }

    @ViewBuilder
    var tabs: some View {
        TabView {
            ForEach(API.ListingType.allCases.filter { $0 != .new }) { type in
                Tab(type.name, systemImage: type.systemImage) {
                    NavigationStack {
                        ListingScreen(type: type)
                            .toolbar {
                                toolbar
                            }
                    }
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

    var body: some View {
        ListingScreen(type: type)
    }
}

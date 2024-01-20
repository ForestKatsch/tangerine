//
//  ListingTab.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI
import SwiftUIIntrospect

struct ListingTab: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @State
    var type: API.ListingType = .news

    @State
    private var item: Item?

    var body: some View {
        NavigationSplitView {
            ListingScreen(type: $type, selection: $item)
                .navigationSplitViewColumnWidth(min: 600, ideal: 900)
        } detail: {
            FetchView(FetchBrowseListing(type: type)) { data in
                NavigationStack {
                    if let item {
                        ItemScreen(item)
                    } else {
                        ProgressView()
                    }
                }
                .onAppear {
                    if horizontalSizeClass == .regular {
                        item = data[0]
                    }
                }
            }
        }
        .introspect(.navigationSplitView, on: .iOS(.v17)) { navigationController in
            navigationController.preferredPrimaryColumnWidthFraction = 0.4
            navigationController.maximumPrimaryColumnWidth = 500
            navigationController.minimumPrimaryColumnWidth = 250
        }
    }
}

#Preview {
    ListingTab()
}

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
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 200, ideal: 300)
            #endif
        } detail: {
//            InfiniteFetchView(FetchBrowseListing(type: type)) { data in
            NavigationStack {
                if let item {
                    ItemScreen(item)
                } else {
                    ProgressView()
                }
            }
            /*
                .onAppear {
                    if data[0].isPlaceholder {
                        return
                    }
                    #if os(macOS)
                        item = data[0]
                    #endif
                    if horizontalSizeClass == .regular {
                        item = data[0]
                    }
                }
             */
//            }
        }
        #if os(iOS)
        .introspect(.navigationSplitView, on: .iOS(.v17)) { navigationController in
            navigationController.preferredPrimaryColumnWidthFraction = 0.35
            navigationController.maximumPrimaryColumnWidth = 400
            navigationController.minimumPrimaryColumnWidth = 200
        }
        #endif
    }
}

#Preview {
    ListingTab()
}

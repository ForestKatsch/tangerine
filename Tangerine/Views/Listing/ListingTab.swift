//
//  ListingTab.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct ListingTab: View {
    @State
    private var column = NavigationSplitViewColumn.sidebar

    @State
    private var item: Item?

    @State
    private var initial: Item?

    @State
    private var visibility = NavigationSplitViewVisibility.automatic

    var body: some View {
        NavigationSplitView(columnVisibility: $visibility, preferredCompactColumn: $column) {
            ListingScreen(selected: $item, initial: $initial)
                .navigationSplitViewColumnWidth(min: 300, ideal: 500)
        } detail: {
            NavigationStack {
                if let item {
                    ItemScreen(item)
                } else {
                    if let initial {
                        ItemScreen(initial)
                            .onAppear {
                                if visibility == .doubleColumn {
                                    item = initial
                                }
                            }
                    } else {
                        ProgressView()
                    }
                }
            }
        }
    }
}

#Preview {
    ListingTab()
}

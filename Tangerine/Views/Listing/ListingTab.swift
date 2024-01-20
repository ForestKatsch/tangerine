//
//  ListingTab.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct ListingTab: View {
    @State
    private var item: Item?

    var body: some View {
        NavigationSplitView {
            ListingScreen(selected: $item)
                .navigationSplitViewColumnWidth(min: 300, ideal: 500)
        } detail: {
            NavigationStack {
                if let item {
                    ItemScreen(item)
                } else {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    ListingTab()
}

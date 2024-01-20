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
    private var post: Post?

    var body: some View {
        NavigationSplitView {
            ListingScreen(type: $type, selection: $post)
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 200, ideal: 300)
            #endif
        } detail: {
            InfiniteFetchView(FetchBrowseListing(type: type)) { data, _, _ in
                NavigationStack {
                    if let post {
                        PostScreen(post)
                    } else {
                        ProgressView()
                    }
                }
                .onAppear {
                    if data.isEmpty || data[0].isEmpty {
                        return
                    }

                    let first = data[0][0]

                    if first.isPlaceholder {
                        return
                    }
                    #if os(macOS)
                        post = first
                    #endif
                    if horizontalSizeClass == .regular {
                        post = first
                    }
                }
            }
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

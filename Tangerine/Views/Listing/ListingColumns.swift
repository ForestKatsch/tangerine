//
//  ListingTab.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI
import SwiftUIIntrospect

struct ListingColumns: View {
    @State
    var type: API.ListingType? = .news

    @State
    private var post: Post?

    #if os(visionOS)
        @State
        private var preferredColumn = NavigationSplitViewColumn.sidebar
    #else
        @State
        private var preferredColumn = NavigationSplitViewColumn.content
    #endif

    var sidebar: some View {
        List(selection: $type) {
            Section {
                ForEach(API.ListingType.allCases) { type in
                    Label(type.name, systemImage: type.systemImage).tag(type)
                }
            }
        }
        .navigationTitle("Tangerine")
    }

    var listing: some View {
        ListingView(type: type ?? .news, selection: $post)
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 300, ideal: 500)
        #endif
    }

    @ViewBuilder
    var detail: some View {
        if let post {
            InfiniteFetchView(FetchPost(postId: post.id)) { commentPages, _, fetchStatus in
                NavigationStack {
                    PostScreen(post.merge(from: commentPages[0]), fetchStatus: fetchStatus)
                        .unredacted()
                }
            }
        } else {
            ProgressView()
        }
    }

    var tripleColumn: some View {
        NavigationSplitView(preferredCompactColumn: $preferredColumn) {
            sidebar
        } content: {
            listing
        } detail: {
            detail
        }
        #if os(iOS)
        .introspect(.navigationSplitView, on: .iOS(.v17)) { navigationController in
            navigationController.preferredSupplementaryColumnWidthFraction = 0.35
        }
        #endif
    }

    var doubleColumn: some View {
        NavigationSplitView(preferredCompactColumn: $preferredColumn) {
            listing
        } detail: {
            detail
        }
        #if os(iOS)
        .introspect(.navigationSplitView, on: .iOS(.v17)) { navigationController in
            navigationController.preferredPrimaryColumnWidthFraction = 0.35
            navigationController.maximumPrimaryColumnWidth = 400
            navigationController.minimumPrimaryColumnWidth = 200
        }
        #endif
    }

    var body: some View {
        #if os(visionOS)
            doubleColumn
        #else
            tripleColumn
        #endif
    }
}

#Preview {
    ListingColumns()
}

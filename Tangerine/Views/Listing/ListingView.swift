//
//  ListingView.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Aquifer
import SwiftUI

extension API.ListingType {
    var name: LocalizedStringKey {
        switch self {
        case .news: "listing.news"
        case .new: "listing.new"
        case .ask: "listing.ask"
        case .show: "listing.show"
        case .jobs: "listing.jobs"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .news: "listing.news.compact"
        case .ask: "listing.ask.compact"
        case .show: "listing.show.compact"
        default: name
        }
    }

    var systemImage: String {
        switch self {
        case .news: "newspaper"
        case .new: "seal"
        case .ask: "questionmark.circle"
        case .show: "lightbulb"
        case .jobs: "briefcase"
        }
    }
}

struct ListingView: View {
    /// A binding, not a value: the picker that switches listings lives in this view's own top
    /// bar, so it writes back to whoever owns the selection.
    @Binding
    var type: API.ListingType

    @Binding
    var selection: Post?

    /// Select the first post as soon as the listing loads, so a detail column isn't empty on
    /// launch. Decided by `ListingScreen`, which can read the window's size class honestly — a
    /// split view's sidebar column reports `.compact` even in a wide window, so asking from in
    /// here would always say "collapsed".
    var selectsFirstPost: Bool

    @InfiniteFetch
    private var listing: InfiniteQueryHandle<FetchBrowseListing>

    init(type: Binding<API.ListingType>, selection: Binding<Post?>, selectsFirstPost: Bool) {
        self._type = type
        self._selection = selection
        self.selectsFirstPost = selectsFirstPost
        self._listing = InfiniteFetch(FetchBrowseListing(type: type.wrappedValue))
    }

    @ViewBuilder
    var content: some View {
        let posts = listing.pages.flatMap { $0 }

        if posts.isEmpty {
            CenteredScrollView {
                if let error = listing.error {
                    ErrorView(error)
                } else {
                    ProgressView()
                }
            }
        } else {
            List(selection: $selection) {
                ForEach(posts, id: \.id) { post in
                    PostRow(post: post)
                        .tag(post)
                }
                InfiniteEnd(error: listing.error) {
                    Task { await listing.fetchNextPage() }
                }
            }
            .scrollIndicators(.hidden)
            .refreshable { await listing.refetch() }
            .onChange(of: posts.count, initial: true) {
                if selectsFirstPost, selection == nil, let first = posts.first {
                    selection = first
                }
            }
        }
    }

    var body: some View {
        content
            .navigationTitle(type.title)
            // The five HN listings are a filter on this one screen, not five destinations, so
            // they sit in a picker under the title rather than taking up the tab bar.
            //
            // `safeAreaBar`, not `safeAreaInset`: the bar version comes with the system's own
            // backdrop and scroll edge effect, so the listing scrolling underneath stays legible
            // without hand-rolling a material behind it.
            .safeAreaBar(edge: .top) {
                Picker("listing.pick", selection: $type) {
                    ForEach(API.ListingType.allCases) { type in
                        Label(type.name, systemImage: type.systemImage).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .labelStyle(.titleOnly)
                .padding(.horizontal, .spacingHorizontal)
                .padding(.bottom, .spacingMedium)
            }
    }
}

/// Loads a post's full body and comments via Aquifer, showing the listing post immediately while
/// the detail loads and merging in the fetched comments when they arrive. Pull-to-refresh refetches.
struct PostDetail: View {
    private let post: Post

    // Plain `Fetch` member rather than the `@Fetch` attribute, so it can be built from `post` in
    // `init`; SwiftUI still drives it as a DynamicProperty.
    private var fetch: Fetch<FetchPost>

    init(post: Post) {
        self.post = post
        self.fetch = Fetch(FetchPost(postId: post.id))
    }

    var body: some View {
        let state = fetch.wrappedValue
        PostScreen(
            post.merge(from: state.value ?? post),
            isLoading: state.value == nil && state.isFetching,
            error: state.error
        )
        .unredacted()
        .id(post.id)
        .refreshable { await fetch.projectedValue.refetch() }
    }
}

/// Vertically centers its content inside a full-height scroll view — used for the listing's empty
/// and error states.
struct CenteredScrollView<Content: View>: View {
    @ViewBuilder
    var content: () -> Content

    var body: some View {
        GeometryReader { geom in
            ScrollView {
                content()
                    .frame(maxWidth: .infinity, minHeight: geom.size.height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// The listing's last row: triggers the next page on appear and shows a loading hint or the
/// pagination error.
struct InfiniteEnd: View {
    var error: Error?
    var next: () -> Void

    var body: some View {
        ZStack(alignment: .center) {
            if let error {
                ErrorView(error)
            } else {
                Text("loading.generic")
                    .textCase(.uppercase)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .listRowSeparator(.hidden)
        .frame(maxWidth: .infinity)
        .onAppear(perform: next)
    }
}

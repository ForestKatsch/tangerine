//
//  ListingScreen.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Aquifer
import SwiftUI

extension API.ListingType {
    var name: LocalizedStringKey {
        switch self {
        case .news:
            return "listing.news"
        case .new:
            return "listing.new"
        case .ask:
            return "listing.ask"
        case .show:
            return "listing.show"
        case .jobs:
            return "listing.jobs"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .news:
            return "listing.news.compact"
        case .ask:
            return "listing.ask.compact"
        case .show:
            return "listing.show.compact"
        default:
            return name
        }
    }

    var systemImage: String {
        switch self {
        case .news:
            return "newspaper"
        case .new:
            return "seal"
        case .ask:
            return "questionmark.circle"
        case .show:
            return "lightbulb"
        case .jobs:
            return "briefcase"
        }
    }
}

struct ListingTypePicker: View {
    @Binding
    var type: API.ListingType

    init(_ type: Binding<API.ListingType>) {
        self._type = type
    }

    var body: some View {
        Picker("listing.pick", selection: $type) {
            ForEach(API.ListingType.allCases) { type in
                Label(type.name, systemImage: type.systemImage).tag(type)
            }
        }
        #if os(macOS)
        .labelStyle(.titleOnly)
        #endif
    }
}

struct ListingView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    var type: API.ListingType

    @Binding
    var selection: Post?

    @InfiniteFetch
    private var listing: InfiniteQueryHandle<FetchBrowseListing>

    init(type: API.ListingType, selection: Binding<Post?>) {
        self.type = type
        self._selection = selection
        self._listing = InfiniteFetch(FetchBrowseListing(type: type))
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
                InfiniteEnd(
                    next: { Task { await listing.fetchNextPage() } },
                    error: listing.error
                )
            }
            .scrollIndicators(.hidden)
            .refreshable { await listing.refetch() }
            .onChange(of: posts.count, initial: true) {
                if posts.isEmpty || selection != nil {
                    return
                }

                let first = posts[0]

                #if os(macOS) || os(visionOS)
                    selection = first
                #endif
                if horizontalSizeClass != .compact {
                    selection = first
                }
            }
        }
    }

    var body: some View {
        content
            .navigationTitle(type.title)
    }
}

// Navigation-pushing wrapper for ListingView
struct ListingScreen: View {
    let type: API.ListingType
    @State private var selection: Post?

    var body: some View {
        ListingView(type: type, selection: $selection)
            .navigationDestination(item: $selection) { post in
                NavigationStack {
                    PostDetail(post: post)
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .all)
    }
}

/// Loads a post's full body and comments via Aquifer, showing the listing post immediately while
/// the detail loads and merging in the fetched comments when they arrive. Pull-to-refresh refetches.
struct PostDetail: View {
    let post: Post

    var body: some View {
        // Generic over the query so `@Fetch` can infer its type from the init argument (it can't be
        // inferred from a `QueryState<Post>` annotation alone) — giving us a `refetch()` handle.
        PostDetailLoader(FetchPost(postId: post.id), listing: post)
    }
}

private struct PostDetailLoader<Q: Query>: View where Q.Value == Post {
    private let listing: Post
    // Plain `Fetch` member (not the `@Fetch` attribute) so `Q` is inferred from the init argument;
    // SwiftUI still drives it as a DynamicProperty. Same pattern Aquifer's own QueryView uses.
    private var fetch: Fetch<Q>

    init(_ query: Q, listing: Post) {
        self.listing = listing
        self.fetch = Fetch(query)
    }

    var body: some View {
        let state = fetch.wrappedValue
        PostScreen(
            listing.merge(from: state.value ?? listing),
            isLoading: state.value == nil && state.isFetching
        )
        .unredacted()
        .id(listing.id)
        .refreshable { await fetch.projectedValue.refetch() }
        .scrollEdgeEffectStyle(.soft, for: .all)
    }
}

/// Vertically centers its content inside a full-height scroll view — used for the listing's empty
/// and error states.
struct CenteredScrollView<Content: View>: View {
    @ViewBuilder
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

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
    var next: () -> Void
    var error: Error?

    var body: some View {
        ZStack(alignment: .center) {
            if error != nil {
                ErrorView(error)
                // TODO: "try again" button
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
        .onAppear {
            next()
        }
    }
}

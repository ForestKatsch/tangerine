//
//  WindowRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/22/23.
//

import SwiftUI

/// A reading tab: a group of HN listings shown on one screen. A feed with more than one listing
/// gets a picker to switch between them; one with a single listing just shows it.
///
/// Adding a tab is adding a case here. `String`-backed so it can key per-feed scene storage.
enum Feed: String, CaseIterable, Identifiable {
    /// The front page, on its own.
    case news
    /// Every other listing, behind a picker.
    case explore

    var id: Self { self }

    /// The listings this feed offers, in picker order. The first is where it opens.
    var listings: [API.ListingType] {
        switch self {
        case .news: [.news]
        // Everything `news` doesn't claim, so a new listing type shows up here by default.
        case .explore: API.ListingType.allCases.filter { !Feed.news.listings.contains($0) }
        }
    }

    var name: LocalizedStringKey {
        switch self {
        case .news: "listing.news"
        case .explore: "listing.explore"
        }
    }

    var systemImage: String {
        switch self {
        case .news: "newspaper"
        case .explore: "binoculars"
        }
    }
}

/// Which tab is showing. `RawRepresentable` so it survives in `@SceneStorage`.
enum AppTab: Hashable, RawRepresentable {
    case feed(Feed)
    case account

    init?(rawValue: String) {
        if rawValue == "account" {
            self = .account
        } else if let feed = Feed(rawValue: rawValue) {
            self = .feed(feed)
        } else {
            return nil
        }
    }

    var rawValue: String {
        switch self {
        case .feed(let feed): feed.rawValue
        case .account: "account"
        }
    }
}

/// The app's only navigation container, on every platform and at every size.
///
/// The tabs are the app's distinct destinations — one per `Feed`, and your account. HN's listings
/// are grouped into those feeds rather than each taking a tab; within a feed they're a filter on
/// one screen, switched from its toolbar.
///
/// Deliberately not `.sidebarAdaptable`: a handful of destinations don't need a sidebar, and that
/// style brings its own sidebar toggle, which lands next to the one the `NavigationSplitView`
/// inside each tab already draws.
struct WindowRoot: View {
    @SceneStorage("selectedTab")
    private var tab: AppTab = .feed(.news)

    var body: some View {
        TabView(selection: $tab) {
            ForEach(Feed.allCases) { feed in
                Tab(feed.name, systemImage: feed.systemImage, value: AppTab.feed(feed)) {
                    ListingScreen(feed: feed)
                }
            }
            Tab("account.label", systemImage: "person.crop.circle", value: AppTab.account) {
                NavigationStack {
                    AccountScreen()
                }
            }
        }
    }
}

/// Reading: a listing, and the post selected within it.
///
/// How the columns are laid out is the system's call, from size class, width and aspect ratio:
/// side by side where there's room, collapsed to a `NavigationStack` at compact widths, and the
/// sidebar overlaid on the detail in between. SwiftUI exposes no way to ask for a particular one
/// (`NavigationSplitViewStyle` has no equivalent of UIKit's `.tile`, and setting that through the
/// underlying `UISplitViewController` is ignored on this OS), so the only lever is which columns
/// show, below. Selection drives navigation in every one of those layouts.
struct ListingScreen: View {
    // Read here rather than inside `ListingView`: a split view's sidebar column reports a compact
    // horizontal size class even in a wide window, so asking from in there would always say
    // "collapsed". Out here it describes the window, which is what decides whether the split view
    // collapses in the first place.
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    private let feed: Feed

    /// Which of the feed's listings is showing. `API.ListingType` is `String`-backed, so it
    /// round-trips through scene storage — keyed per feed — and each tab reopens on the listing it
    /// was left on.
    @SceneStorage
    private var type: API.ListingType

    @State
    private var post: Post?

    /// Start with the listing showing. Where the split view lays the columns out side by side this
    /// is what it would do anyway; where it slides the sidebar over the detail instead — a phone
    /// wide enough to count as `.regular`, like an unfolded Duo — the default is a *closed*
    /// overlay, which launches the app onto an empty detail with the listing nowhere in sight.
    @State
    private var columnVisibility: NavigationSplitViewVisibility = .all

    init(feed: Feed) {
        self.feed = feed
        self._type = SceneStorage(wrappedValue: feed.listings[0], "listingType.\(feed.rawValue)")
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ListingView(
                type: $type,
                listings: feed.listings,
                selection: $post,
                selectsFirstPost: horizontalSizeClass != .compact
            )
            .navigationSplitViewColumnWidth(min: 280, ideal: 360, max: 480)
        } detail: {
            if let post {
                NavigationStack {
                    PostDetail(post: post)
                        .handleInAppLinks()
                }
            } else {
                ContentUnavailableView("listing.post.none", systemImage: "newspaper")
            }
        }
        // The selected post belongs to the listing it came from.
        .onChange(of: type) {
            post = nil
        }
        // A `NavigationSplitView` nested in a `Tab` doesn't extend its columns under the status
        // bar the way it does on its own — it gets clipped below, leaving a bare strip across the
        // top. Letting it own that edge puts the column backgrounds back under the status bar;
        // the split view still insets its own bars and content normally.
        .ignoresSafeArea(.container, edges: .top)
    }
}

#Preview {
    WindowRoot()
}

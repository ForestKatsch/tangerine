//
//  WindowRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/22/23.
//

import SwiftUI

/// Which tab is showing. `RawRepresentable` so it survives in `@SceneStorage`.
enum AppTab: String {
    case news
    case account
}

/// The app's only navigation container, on every platform and at every size.
///
/// The tabs are the app's distinct destinations — reading and your account — not HN's five
/// listings, which are one screen with a filter on it and live in the picker under its title.
///
/// Deliberately not `.sidebarAdaptable`: two destinations don't need a sidebar, and that style
/// brings its own sidebar toggle, which lands next to the one the `NavigationSplitView` inside
/// each tab already draws.
struct WindowRoot: View {
    @SceneStorage("selectedTab")
    private var tab: AppTab = .news

    var body: some View {
        TabView(selection: $tab) {
            Tab("listing.news", systemImage: "newspaper", value: AppTab.news) {
                ListingScreen()
            }
            Tab("account.label", systemImage: "person.crop.circle", value: AppTab.account) {
                AccountTab()
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

    /// Which listing is showing. `API.ListingType` is `String`-backed, so it round-trips through
    /// scene storage and the app reopens on the feed it was left on.
    @SceneStorage("listingType")
    private var type: API.ListingType = .news

    @State
    private var post: Post?

    /// Start with the listing showing. Where the split view lays the columns out side by side this
    /// is what it would do anyway; where it slides the sidebar over the detail instead — a phone
    /// wide enough to count as `.regular`, like an unfolded Duo — the default is a *closed*
    /// overlay, which launches the app onto an empty detail with the listing nowhere in sight.
    @State
    private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ListingView(
                type: $type,
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

/// Your account, and the settings reachable from it.
private struct AccountTab: View {
    var body: some View {
        NavigationStack {
            AccountScreen()
        }
    }
}

#Preview {
    WindowRoot()
}

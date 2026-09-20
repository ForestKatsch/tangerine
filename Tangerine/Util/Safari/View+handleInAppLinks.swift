//
//  View+handleOpenUrlInApp.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/7/25.
//

import SwiftUI

#if os(iOS)
    import WebKit

    /// An in-app browser, pushed onto the enclosing stack like any other screen.
    ///
    /// `WebView` is an ordinary SwiftUI view, so the stack gives it its navigation bar, safe areas
    /// and back gesture. `SFSafariViewController` is documented for *modal* presentation — pushing
    /// one means hiding the bars it collides with and hand-rolling the pop from its delegate.
    struct WebScreen: View {
        let url: URL

        @State
        private var page = WebPage()

        private var title: String {
            page.title.isEmpty ? (url.host() ?? url.absoluteString) : page.title
        }

        var body: some View {
            WebView(page)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(item: page.url ?? url)
                    }
                }
                .onAppear {
                    _ = page.load(url)
                }
        }
    }

    /// Monitors the `openURL` environment variable and handles them in-app instead of via
    /// the external web browser.
    private struct InAppLinksModifier: ViewModifier {
        @State
        private var urlToOpen: URL?

        func body(content: Content) -> some View {
            content
                .environment(\.openURL, OpenURLAction { url in
                    /// Catch any URLs that are about to be opened in an external browser.
                    /// Instead, handle them here and push the URL onto the enclosing stack.
                    urlToOpen = url
                    return .handled
                })
                .navigationDestination(item: $urlToOpen) { url in
                    WebScreen(url: url)
                }
        }
    }
#else
    private struct InAppLinksModifier: ViewModifier {
        @Environment(\.openURL) var openURL
        func body(content: Content) -> some View {
            content
                .environment(\.openURL, OpenURLAction { url in
                    openURL(url)
                    return .handled
                })
        }
    }
#endif

extension View {
    /// Monitor the `openURL` environment variable and handle them in-app instead of via
    /// the external web browser, pushing a `WebScreen` onto the enclosing `NavigationStack`.
    ///
    /// Apply this **once per navigation stack**, on a view inside the stack — the override travels
    /// down the environment to every link below it, and a stack can only declare one
    /// `navigationDestination` per type.
    func handleInAppLinks() -> some View {
        modifier(InAppLinksModifier())
    }
}

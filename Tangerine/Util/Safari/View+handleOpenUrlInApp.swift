//
//  View+handleOpenUrlInApp.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/7/25.
//

import SwiftUI

#if os(iOS)
    /// Monitors the `openURL` environment variable and handles them in-app instead of via
    /// the external web browser.
    private struct SafariViewControllerViewModifier: ViewModifier {
        @State
        private var urlToOpen: URL?

        func body(content: Content) -> some View {
            content
                .environment(\.openURL, OpenURLAction { url in
                    /// Catch any URLs that are about to be opened in an external browser.
                    /// Instead, handle them here and store the URL to reopen in our sheet.
                    urlToOpen = url
                    return .handled
                })
                .sheet(isPresented: $urlToOpen.hasValue(), onDismiss: {
                    urlToOpen = nil
                }, content: {
                    SFSafariView(url: urlToOpen!)
                })
        }
    }
#endif

extension View {
    /// Monitor the `openURL` environment variable and handle them in-app instead of via
    /// the external web browser.
    /// Uses the `SafariViewWrapper` which will present the URL in a `SFSafariViewController`.
    #if os(iOS)
        func openLinksInSafari() -> some View {
            modifier(SafariViewControllerViewModifier())
        }
    #else
        func openLinksInSafari() -> some View {
            self
        }
    #endif
}

//
//  View+handleOpenUrlInApp.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/7/25.
//

import SwiftUI

#if os(iOS)
    import SafariServices

    /// A link waiting to be shown. `Identifiable` so the presentation binding doesn't have to
    /// force-unwrap a URL back out of separate state.
    private struct InAppLink: Identifiable {
        let url: URL
        var id: URL { url }
    }

    /// Safari's own browser, for reading a page rather than embedding one.
    ///
    /// Worth the UIKit wrapper over SwiftUI's `WebView`: this is the only way to get Reader,
    /// AutoFill, Fraudulent Website Warning, content blockers and cookies shared with Safari, none
    /// of which `WKWebView` can reach — its `websiteDataStore` is app-private by design.
    private struct SFSafariView: UIViewControllerRepresentable {
        let url: URL

        /// Safari's Done button notifies its delegate rather than dismissing anything itself, so
        /// the presenting view has to clear the binding.
        var onFinish: () -> Void = {}

        func makeCoordinator() -> Coordinator {
            Coordinator(onFinish: onFinish)
        }

        func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
            let viewController = SFSafariViewController(url: url)
            viewController.delegate = context.coordinator
            return viewController
        }

        func updateUIViewController(_: SFSafariViewController, context: UIViewControllerRepresentableContext<Self>) {
            context.coordinator.onFinish = onFinish
        }

        final class Coordinator: NSObject, SFSafariViewControllerDelegate {
            var onFinish: () -> Void

            init(onFinish: @escaping () -> Void) {
                self.onFinish = onFinish
            }

            func safariViewControllerDidFinish(_: SFSafariViewController) {
                onFinish()
            }
        }
    }

    /// Monitors the `openURL` environment variable and handles them in-app instead of via
    /// the external web browser.
    private struct InAppLinksModifier: ViewModifier {
        @State
        private var link: InAppLink?

        func body(content: Content) -> some View {
            content
                .environment(\.openURL, OpenURLAction { url in
                    /// Catch any URLs that are about to be opened in an external browser and show
                    /// them here instead.
                    link = InAppLink(url: url)
                    return .handled
                })
                // Full screen rather than a sheet: Apple's guidance is to present this modally in
                // the default style, and specifically not to use a page or form sheet "to display
                // content from websites".
                .fullScreenCover(item: $link) { link in
                    SFSafariView(url: link.url) { self.link = nil }
                        .ignoresSafeArea()
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
    /// Monitor the `openURL` environment variable and handle them in-app instead of via the
    /// external web browser, presenting Safari over the whole window.
    ///
    /// The override travels down the environment to every link below it, so apply this once per
    /// screen that contains links rather than once per link.
    func handleInAppLinks() -> some View {
        modifier(InAppLinksModifier())
    }
}

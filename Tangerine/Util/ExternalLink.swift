//
//  SFSafariViewController.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SafariServices
import SwiftUI

#if canImport(UIKit)
    import UIKit

    extension UIApplication {
        var firstKeyWindow: UIWindow? {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
                .first?.keyWindow
        }
    }
#endif

struct ExternalLink<Content: View>: View {
    @Environment(\.isFocused)
    var isFocused

    var url: URL

    @ViewBuilder
    var label: () -> Content

    init(_ url: URL, @ViewBuilder label: @escaping () -> Content) {
        self.url = url
        self.label = label
    }

    var safariView: some View {
        Button(action: {
            #if !os(macOS)
                let vc = SFSafariViewController(url: url)
                UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
            #endif
        }) {
            label()
        }
    }

    var linkView: some View {
        Link(destination: url) {
            label()
        }
    }

    var automaticView: some View {
        safariView
    }

    var wrapperView: some View {
        #if os(visionOS) || os(macOS)
            linkView
        #else
            automaticView
        #endif
    }

    var body: some View {
        wrapperView
        #if os(visionOS)
        .buttonStyle(.bordered)
        #elseif os(iOS)
        .foregroundStyle(.accent)
        .buttonStyle(.plain)
        #endif
        .contextMenu {
            OpenLink(destination: url)
            CopyLink(destination: url)
            ShareLink(item: url)
        }
    }
}

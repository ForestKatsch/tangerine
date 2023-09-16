//
//  SFSafariViewController.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SafariServices
import SwiftUI
import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}

struct ExternalLink<Content: View>: View {
    var url: URL

    @ViewBuilder
    var label: () -> Content

    init(_ url: URL, @ViewBuilder label: @escaping () -> Content) {
        self.url = url
        self.label = label
    }

    var safariView: some View {
        Button(action: {
            let vc = SFSafariViewController(url: url)
            UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
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
        #if os(visionOS)
            linkView
        #else
            automaticView
        #endif
    }

    var body: some View {
        wrapperView
            .buttonStyle(.plain)
            .foregroundStyle(.accent)
            .contextMenu {
                OpenLink(destination: url)
                CopyLink(destination: url)
                ShareLink(item: url)
            }
    }
}

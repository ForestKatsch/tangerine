//
//  SFSafariViewController.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import BetterSafariView
import Foundation
import SwiftUI

#if os(iOS)
    let supportsSafariView = true
#else
    let supportsSafariView = false
#endif

struct PlainExternalLink<Content: View>: View {
    @Environment(\.isFocused)
    var isFocused

    @State
    private var presentingSafariView = false

    var url: URL

    @ViewBuilder
    var label: () -> Content

    init(_ url: URL, @ViewBuilder label: @escaping () -> Content) {
        self.url = url
        self.label = label
    }

    #if os(iOS)
        var safariView: some View {
            Button(action: {
                presentingSafariView = true
            }) {
                label()
            }
            .safariView(isPresented: $presentingSafariView) {
                SafariView(
                    url: url,
                    configuration: SafariView.Configuration(
                        entersReaderIfAvailable: false,
                        barCollapsingEnabled: true
                    )
                )
                .preferredControlAccentColor(.accent)
                .dismissButtonStyle(.done)
            }
        }
    #else
        var safariView: some View {
            Text("oh no")
        }
    #endif

    var linkView: some View {
        Link(destination: url) {
            label()
        }
    }

    @ViewBuilder
    var wrapperView: some View {
        if supportsSafariView {
            safariView
        } else {
            linkView
        }
    }

    var body: some View {
        wrapperView
            .contextMenu {
                OpenLink(destination: url)
                CopyLink(destination: url)
                ShareLink(item: url)
            }
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

    var body: some View {
        PlainExternalLink(url, label: label)
        #if os(visionOS)
            .buttonStyle(.bordered)
        #elseif os(iOS)
            .foregroundStyle(.accent)
            .buttonStyle(.plain)
        #endif
    }
}

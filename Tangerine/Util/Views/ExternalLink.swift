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

struct ExternalLink<Content: View>: View {
    @State
    private var presentingSafariView = false

    @Environment(\.isFocused)
    var isFocused

    var url: URL

    @ViewBuilder
    var label: () -> Content

    init(_ url: URL, @ViewBuilder label: @escaping () -> Content) {
        self.url = url
        self.label = label
    }

    #if supportsSafariView
        var safariView: some View {
            Button(action: {
                #if !os(macOS)
                    self.presentingSafariView = true
                #endif
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
                .preferredControlAccentColor(.accentColor)
                .dismissButtonStyle(.done)
            }
        }
    #else
        var safariView: some View {
            EmptyView()
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
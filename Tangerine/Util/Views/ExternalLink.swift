//
//  SFSafariViewController.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SwiftUI

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
            Link(destination: url) {
                label()
            }
            .openLinksInSafari()
        }
    #else
        var safariView: some View {
            linkView
        }
    #endif

    var linkView: some View {
        Link(destination: url) {
            label()
        }
    }

    var body: some View {
        safariView
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

//
//  ExternalLink.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

/// A link out of the app, with a context menu to open, copy or share it.
struct PlainExternalLink<Content: View>: View {
    var url: URL

    @ViewBuilder
    var label: () -> Content

    init(_ url: URL, @ViewBuilder label: @escaping () -> Content) {
        self.url = url
        self.label = label
    }

    var body: some View {
        Link(destination: url, label: label)
            .contextMenu {
                OpenLink(destination: url)
                CopyLink(destination: url)
                #if !os(tvOS)
                    ShareLink(item: url)
                #endif
            }
    }
}

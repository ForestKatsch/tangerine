//
//  PostMenu.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct PostMenu: View {
    var post: Post

    var body: some View {
        #if !os(tvOS)
            LinkActions(
                url: post.hnUrl, share: "share.post.hnUrl", copy: "copy.post.hnUrl",
                systemImage: "bubble.left.and.bubble.right"
            )
            if let link = post.link {
                Section(link.host() ?? "share.post.link") {
                    LinkActions(url: link, share: "share.post.link", copy: "copy.post.link", systemImage: "globe")
                }
            }
        #endif
    }
}

/// Share a URL and, on macOS, where the share sheet has no "Copy", copy it.
private struct LinkActions: View {
    var url: URL
    var share: LocalizedStringKey
    var copy: LocalizedStringKey
    var systemImage: String

    var body: some View {
        ShareLink(item: url) {
            Label(share, systemImage: systemImage)
        }
        #if os(macOS)
            CopyLink(destination: url, label: copy)
        #endif
    }
}

#Preview {
    PostMenu(post: .placeholder)
}

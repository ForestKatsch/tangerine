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
        #if os(macOS)
            CopyLink(destination: post.hnUrl, label: "copy.post.hnUrl")
        #endif
        #if !os(tvOS)
            ShareLink(item: post.hnUrl) {
                Label("share.post.hnUrl", systemImage: "bubble.left.and.bubble.right")
            }
            if let link = post.link {
                Section(link.host() ?? "share.post.link") {
                    ShareLink(item: link) {
                        Label("share.post.link", systemImage: "globe")
                    }
                    #if os(macOS)
                        CopyLink(destination: post.hnUrl, label: "copy.post.link")
                    #endif
                }
            }
        #endif
    }
}

#Preview {
    PostMenu(post: .placeholder)
}

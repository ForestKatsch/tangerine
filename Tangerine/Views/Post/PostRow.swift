//
//  PostRow.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct PostRow: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    var post: Post

    @ViewBuilder
    var scoreView: some View {
        if let score = post.score {
            HStack(spacing: .spacingSmall) {
                Image(systemName: "arrowtriangle.up")
                Text(Formatter.format(intToAbbreviation: score))
            }
        }
    }

    @ViewBuilder
    var authorView: some View {
        if let authorId = post.authorId {
            HStack(spacing: .spacingSmall) {
                Image(systemName: "person.fill")
                    .imageScale(.small)
                Text(authorId)
            }
        } else {
            // Should not happen - this view is only called if authorId is valid.
            EmptyView()
        }
    }

    @ViewBuilder
    var commentCountView: some View {
        if let commentCount = post.commentCount {
            HStack(spacing: .spacingSmall) {
                Image(systemName: "text.bubble")
                Text(Formatter.format(intToAbbreviation: commentCount))
            }
        }
    }

    @ViewBuilder
    var postedDateView: some View {
        if let date = post.postedDate {
            Text(date.formatted(.relative(presentation: .named)))
        }
    }

    @ViewBuilder
    var sublineView: some View {
        HStack(spacing: .spacingMedium) {
            scoreView
            authorView
            Spacer()
            commentCountView
        }
    }

    @ViewBuilder
    var infoView: some View {
        if post.kind != .normal {
            HStack {
                if let kind = post.kind {
                    Image(systemName: kind.systemImage)
                }
                Spacer()
                postedDateView
            }
        } else {
            HStack {
                linkView
                Spacer()
                postedDateView
            }
            sublineView
        }
    }

    @ViewBuilder
    var linkView: some View {
        if let url = post.link {
            Text(Formatter.format(urlHost: url))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingSmall) {
            // Title should NEVER be missing, so if it's empty, that's fine.
            Text(post.title ?? "")
                .font(.headline.weight(.medium))
                .lineLimit(2)
            infoView
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .contextMenu {
            // TODO: implement these actions!
            /*
             Button(action: {}) {
                 Label("Vote up", systemImage: "arrow.up")
             }
             Button(action: {}) {
                 Label("Flag", systemImage: "flag")
             }
             Button(action: {}) {
                 Label("Hide", systemImage: "eye.slash")
             }
              */
            #if os(macOS)
                CopyLink(destination: post.hnUrl, label: "Copy HN link")
            #endif
            ShareLink(item: post.hnUrl)
        }
    }
}

#Preview {
    PostRow(post: .placeholder)
}

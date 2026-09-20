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
        // Dim visited posts with opacity rather than a conditional `.foregroundStyle`: a
        // conditional modifier changes the row's identity (so SwiftUI replaces the row instead of
        // restyling it), and an explicit foreground style would stop the list from recoloring the
        // row's text when it's selected.
        .opacity(ReadManager.shared.hasVisited(post) ? 0.55 : 1)
        .contextMenu {
            PostMenu(post: post)
        }
    }
}

#Preview {
    PostRow(post: .placeholder)
}

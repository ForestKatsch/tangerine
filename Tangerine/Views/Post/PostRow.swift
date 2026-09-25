//
//  PostRow.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct PostRow: View {
    var post: Post

    /// An icon and a short value, like the score or comment count.
    private func stat(_ systemImage: String, _ value: String, imageScale: Image.Scale = .medium) -> some View {
        HStack(spacing: .spacingSmall) {
            Image(systemName: systemImage)
                .imageScale(imageScale)
            Text(value)
        }
    }

    @ViewBuilder
    var score: some View {
        if let score = post.score {
            stat("arrowtriangle.up", Formatter.format(intToAbbreviation: score))
        }
    }

    @ViewBuilder
    var author: some View {
        if let authorId = post.authorId {
            stat("person.fill", authorId, imageScale: .small)
        }
    }

    @ViewBuilder
    var commentCount: some View {
        if let commentCount = post.commentCount {
            stat("text.bubble", Formatter.format(intToAbbreviation: commentCount))
        }
    }

    @ViewBuilder
    var postedDate: some View {
        if let date = post.postedDate {
            Text(date.formatted(.relative(presentation: .named)))
        }
    }

    @ViewBuilder
    var host: some View {
        if let url = post.link {
            Text(Formatter.format(urlHost: url))
        }
    }

    @ViewBuilder
    var info: some View {
        if post.kind != .normal {
            HStack {
                if let kind = post.kind {
                    Image(systemName: kind.systemImage)
                }
                Spacer()
                postedDate
            }
        } else {
            HStack {
                host
                Spacer()
                postedDate
            }
            HStack(spacing: .spacingMedium) {
                score
                author
                Spacer()
                commentCount
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingSmall) {
            // Title should NEVER be missing, so if it's empty, that's fine.
            Text(post.title ?? "")
                .font(.headline.weight(.medium))
                .lineLimit(2)
            info
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

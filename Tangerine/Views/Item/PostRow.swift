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

    var selected: Bool = false

    var tappableItemsInList: Bool {
        #if os(visionOS)
            return false
        #endif
        return horizontalSizeClass == .compact && !selected
    }

    @ViewBuilder
    var scoreView: some View {
        if let score = post.score {
            HStack(spacing: .spacingSmall) {
                Image(systemName: "arrow.up")
                Text(Formatter.format(intToAbbreviation: score))
            }
        }
    }

    @ViewBuilder
    var authorContents: some View {
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
    var authorView: some View {
        if post.authorId != nil {
            if tappableItemsInList {
                Button(action: {}) {
                    authorContents
                }
                .buttonStyle(.borderless)
            } else {
                authorContents
            }
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
        if post.kind != .normal {
            HStack {
                if let kind = post.kind {
                    Image(systemName: kind.systemImage)
                }
            }
        } else {
            HStack(spacing: .spacingMedium) {
                scoreView
                authorView
                Spacer()
                commentCountView
            }
        }
    }

    @ViewBuilder
    var linkContentsView: some View {
        if let url = post.link {
            Text(Formatter.format(urlHost: url))
        }
    }

    @ViewBuilder
    var linkView: some View {
        if let url = post.link {
            if tappableItemsInList {
                ExternalLink(url) {
                    linkContentsView
                }
                .buttonStyle(.borderless)
                #if os(iOS)
                    .foregroundStyle(.secondary)
                #endif
            } else {
                linkContentsView
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingSmall) {
            // Title should NEVER be missing, so if it's empty, that's fine.
            Text(post.title ?? "")
                .font(.headline.weight(.medium))
                .lineLimit(2)
            if post.link != nil {
                HStack {
                    linkView
                    Spacer()
                    postedDateView
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
            }
            sublineView
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
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
            if let url = post.link {
                Section(Formatter.format(urlWithoutPrefix: url)) {
                    OpenLink(destination: url)
                    ShareLink(item: url) {
                        Label("Share link", systemImage: "link")
                    }
                }
            }
        }
    }
}

#Preview {
    PostRow(post: .placeholder)
}

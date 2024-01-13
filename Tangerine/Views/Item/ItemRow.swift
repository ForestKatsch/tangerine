//
//  ItemRow.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

#if os(visionOS)
    let tappableItemsInList = false
#else
    let tappableItemsInList = true
#endif

struct ItemRow: View {
    var item: Item

    @ViewBuilder
    var scoreView: some View {
        if let score = item.score {
            HStack(spacing: .spacingSmall) {
                Image(systemName: "arrow.up")
                Text(Formatter.format(intToAbbreviation: score))
            }
        }
    }

    @ViewBuilder
    var authorContents: some View {
        if let authorId = item.authorId {
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
        if item.authorId != nil {
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
        if let commentCount = item.commentCount {
            HStack(spacing: .spacingSmall) {
                Image(systemName: "text.bubble")
                Text(Formatter.format(intToAbbreviation: commentCount))
            }
        }
    }

    @ViewBuilder
    var postedDateView: some View {
        if let date = item.postedDate {
            Text(date.formatted(.relative(presentation: .named)))
        }
    }

    @ViewBuilder
    var sublineView: some View {
        if item.kind != .normal {
            HStack {
                if let kind = item.kind {
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
        if let url = item.link {
            HStack(spacing: .spacingSmall) {
                if tappableItemsInList {
                    Image(systemName: "link")
                        .imageScale(.small)
                }
                Text(Formatter.format(urlHost: url))
            }
        }
    }

    @ViewBuilder
    var linkView: some View {
        if let url = item.link {
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
            Text(item.title ?? "")
                .font(.headline.weight(.medium))
            if item.link != nil {
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
                CopyLink(destination: item.hnUrl, label: "Copy comments link")
            #endif
            ShareLink(item: item.hnUrl)
            if let url = item.link {
                Section(Formatter.format(urlWithoutPrefix: url)) {
                    OpenLink(destination: url)
                    ShareLink(item: url) {
                        Label("Share Link", systemImage: "link")
                    }
                }
            }
        }
    }
}

#Preview {
    ItemRow(item: .placeholder)
}

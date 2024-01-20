//
//  PostScreen.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

#if os(visionOS) || os(macOS)
    private let nativeTitle = true
#else
    private let nativeTitle = false
#endif

struct PostScreen: View {
    var post: Post

    init(_ post: Post) {
        self.post = post
    }

    var title: LocalizedStringKey {
        if let title = post.title {
            return "\(title)"
        }

        if let commentCount = post.commentCount {
            return "\(commentCount, format: .number) comments"
        }

        return "\(post.id)"
    }

    @ViewBuilder
    var linkView: some View {
        if let url = post.link {
            ExternalLink(url) {
                HStack(alignment: .firstTextBaseline, spacing: .spacingSmall) {
                    Label(Formatter.format(urlWithoutPrefix: url), systemImage: "link")
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                }
            }
            .font(.footnote)
        }
    }

    @ViewBuilder
    var titleView: some View {
        if let title = post.title {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
        }
    }

    @ViewBuilder
    var scoreView: some View {
        PostScoreView(post: post)
    }

    @ViewBuilder
    var authorView: some View {
        if let authorId = post.authorId {
            Label(authorId, systemImage: "person.fill")
                .foregroundStyle(.secondary)
                .fixedSize()
        }
    }

    @ViewBuilder
    var postedDateView: some View {
        if let date = post.postedDate {
            Text(date.formatted(.relative(presentation: .named)))
                .foregroundStyle(.secondary)
                .help(date.formatted())
        }
    }

    @ViewBuilder
    var infoLeadingView: some View {
        if post.kind == .job {
            Image(systemName: Post.Kind.job.systemImage)
        } else {
            HStack(spacing: .spacingMedium) {
                scoreView
                authorView
            }
        }
    }

    @ViewBuilder
    var infoView: some View {
        HStack(spacing: .spacingMedium) {
            infoLeadingView
            Spacer()
            postedDateView
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    var headerView: some View {
        VStack(alignment: .leading, spacing: .spacingLarge) {
            if !nativeTitle {
                titleView
            }
            linkView
            infoView
            #if os(visionOS)
            .frame(minHeight: 50)
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var commentsView: some View {
        VStack {
            ContentUnavailableView("Comments not implemented yet", systemImage: "exclamationmark.bubble")
            ExternalLink(post.hnUrl) {
                Label("Browse comments", systemImage: "globe")
            }
        }
    }

    var body: some View {
        CenteredScrollView {
            VStack(alignment: .leading) {
                headerView
                    .padding(.bottom)
                    .padding(.horizontal, .spacingHorizontal)
                    .padding(.top)
                ZStack(alignment: .center) {
                    commentsView
                        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .padding(.horizontal, .spacingHorizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toolbar {
            ToolbarItem {
                ShareLink("Share", item: post.hnUrl)
            }
        }
        .navigationTitle(nativeTitle ? title : "")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    PostScreen(.placeholder)
}

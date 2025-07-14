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

    var fetchStatus: FetchStatus

    init(_ post: Post, fetchStatus: FetchStatus = .init(fetchState: .idle, isFetching: false, isLoading: false, error: nil)) {
        self.post = post
        self.fetchStatus = fetchStatus
    }

    var title: LocalizedStringKey {
        if let title = post.title {
            return "\(title)"
        }

        if let commentCount = post.commentCount {
            return "\(commentCount) comments"
        }

        return "\(post.id)"
    }

    @ViewBuilder
    var linkView: some View {
        if let url = post.link {
            ProminentExternalLink(url)
        }
    }

    var isLoading: Bool {
        FetchInstanceCache.shared.get(infinite: FetchPost(postId: post.id)).isLoading
    }

    @ViewBuilder
    var contentView: some View {
        linkView
        if let text = post.text {
            HNTextView(text)
        } else if post.likelyToContainText && isLoading {
            HNTextView("Hi! This is just a few phony lines to make it appear as if we're currently loading some text. Don't worry though, it's a placeholder!\n\nAnd another paragraph to make it look longer :) and a link to [https://google.com/] to see if that shows up in the placeholder.")
                .redacted(reason: .placeholder)
        }
    }

    @ViewBuilder
    var titleView: some View {
        if let title = post.title {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
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
            Label(Post.Kind.job.name, systemImage: Post.Kind.job.systemImage)
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
            contentView
            infoView
            #if os(visionOS)
            .frame(minHeight: 50)
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var commentsView: some View {
        VStack(spacing: .spacingHuge) {
            CommentTree(post.comments, post: post)
            if fetchStatus.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical)
            } else if post.comments.isEmpty {
                ContentUnavailableView("post.comments.none", systemImage: "bubble")
                    .padding(.vertical)
            }
        }
        .padding(.bottom)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingLarge) {
                headerView
                    .padding(.top)
                    .padding(.horizontal, .spacingHorizontal)
                Divider()
                commentsView
                    .padding(.horizontal, .spacingHorizontal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators((post.commentCount ?? 0) > 5 ? .hidden : .automatic)
        .id(post.id)
        .toolbar {
            ToolbarItem {
                Menu { PostMenu(post: post) } label: {
                    Label("listing.post.more", systemImage: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            withAnimation {
                ReadManager.shared.markVisited(post)
            }
        }
        .navigationTitle(nativeTitle ? title : "")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    PostScreen(.placeholder, fetchStatus: .init(fetchState: .idle, isFetching: false, isLoading: false, error: nil))
}

//
//  CommentView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import SwiftUI

struct CommentView: View {
    var comment: Comment
    var post: Post?

    init(_ comment: Comment, post: Post? = nil) {
        self.comment = comment
        self.post = post
    }

    @ViewBuilder
    var author: some View {
        if let authorId = comment.authorId {
            let isOp = authorId == post?.authorId

            HStack {
                if isOp {
                    Label(authorId, systemImage: "person.fill")
                        .fixedSize()
                } else {
                    Text(authorId)
                        .fixedSize()
                }
            }
            .font(isOp ? .subheadline.bold() : .subheadline)
        }
    }

    @ViewBuilder
    var postedDate: some View {
        if let date = comment.postedDate {
            Text(date.formatted(.relative(presentation: .named)))
                .help(date.formatted())
        }
    }

    var header: some View {
        HStack {
            author
            postedDate
            Spacer()
            Menu {
                ShareLink(item: comment.hnUrl) {
                    Label("share.post.comment.hnUrl", systemImage: "bubble.left.and.bubble.right")
                }
            } label: {
                Label("post.comment.more", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .frame(width: .icon, height: .icon)
                    .contentShape(RoundedRectangle(cornerRadius: .radius))
            }
            .menuIndicator(.hidden)
        }
        .foregroundStyle(.secondary)
        .font(.subheadline)
    }

    var body: some View {
        VStack(spacing: .spacingMedium) {
            header
            HNTextView(comment.text ?? "! (Error: no text for this comment)")
                .opacity(comment.opacity)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .id(comment.id)
    }
}

#Preview {
    CommentView(Comment(id: "hi", text: "Hello, world"))
}

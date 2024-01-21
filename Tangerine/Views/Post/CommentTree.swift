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
    var authorView: some View {
        let isOp = comment.authorId == post?.authorId

        if let authorId = comment.authorId {
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
            authorView
            postedDate
            Spacer()
        }
        .foregroundStyle(.secondary)
        .font(.subheadline)
    }

    var body: some View {
        VStack {
            header
            HNTextView(comment.text ?? "oh no")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        /*
         .overlay {
             RoundedRectangle(cornerRadius: 10)
                 .stroke(.fill)
         }
          */
        .id(comment.id)
    }
}

struct CommentTree: View {
    var comment: Comment
    var post: Post?

    init(_ comment: Comment, post: Post? = nil) {
        self.comment = comment
        self.post = post
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var indent: CGFloat {
        horizontalSizeClass == .compact ? 10 : 15
    }

    static let commentSpacing: CGFloat = .spacingLarge

    static let indentBarSize: CGFloat = 2

    var indentColor: Color {
        switch comment.indent {
        case 0:
            .red
        case 1:
            .orange
        case 2:
            .yellow
        case 3:
            .green
        case 4:
            .teal
        case 5:
            .blue
        case 6:
            .purple
        default:
            .accentColor
        }
    }

    var children: some View {
        HStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(indentColor.opacity(0.5))
                    .frame(width: CommentTree.indentBarSize)
                    .frame(maxHeight: .infinity)
                    .offset(x: -CommentTree.indentBarSize / 2)
                Spacer()
                    .frame(width: indent)
            }

            LazyVStack(spacing: CommentTree.commentSpacing) {
                ForEach(Array(zip(comment.children.indices, comment.children)), id: \.0) { index, reply in
                    if index != 0 {
                        // Divider()
                    }
                    CommentTree(reply, post: post)
                }
            }
        }
        // .padding(.bottom)
    }

    var body: some View {
        VStack(spacing: CommentTree.commentSpacing) {
            CommentView(comment, post: post)
            if !comment.children.isEmpty {
                children
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .id(comment.id + "-tree")
    }
}

#Preview {
    CommentView(Comment(id: "hi", text: "Hello, world"))
}

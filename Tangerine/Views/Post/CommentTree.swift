//
//  CommentView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import Defaults
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
            /*
             Button(action: {}) {
                 Label("More", systemImage: "ellipsis")
                     .labelStyle(.iconOnly)
             }
             .fixedSize()
              */
        }
        .foregroundStyle(.secondary)
        .font(.subheadline)
    }

    var body: some View {
        LazyVStack(spacing: .spacingMedium) {
            header
            HNTextView(comment.text ?? "!")
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(comment.id)
        }
        .id(comment.id)
    }
}

struct CommentTree: View {
    @Default(.commentPalette)
    var commentPalette

    @Default(.commentTreeMode)
    var commentTreeMode

    enum Mode: Int, Identifiable, Defaults.Serializable, CaseIterable {
        var id: Self { self }
        case nested
        case paged
    }

    enum IndentPalette: Int, Identifiable, Defaults.Serializable, CaseIterable {
        var id: Self { self }
        case colorful
        case minimal
    }

    var comments: [Comment]
    var post: Post?

    init(_ comments: [Comment], post: Post? = nil) {
        self.comments = comments
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
        if commentPalette == .minimal {
            .gray
        } else {
            switch comments[0].indent % 7 {
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
                .gray
            }
        }
    }

    var nestedDepth: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
            #if os(visionOS)
                .fill(indentColor)
            #else
                .fill(indentColor.opacity(0.5))
            #endif
                .frame(width: CommentTree.indentBarSize)
                .frame(maxHeight: .infinity)
                .offset(x: -CommentTree.indentBarSize / 2)
            Spacer()
                .frame(width: indent)
        }
    }

    var nested: some View {
        LazyVStack(spacing: CommentTree.commentSpacing) {
            ForEach(comments) { comment in
                CommentView(comment, post: post)
                if !comment.children.isEmpty {
                    HStack {
                        nestedDepth
                        CommentTree(comment.children, post: post)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var paged: some View {
        ScrollView(.horizontal) {
            ForEach(comments) { comment in
                LazyVStack {
                    CommentView(comment, post: post)
                    if !comment.children.isEmpty {
                        CommentTree(comment.children, post: post)
                    }
                }
            }
        }
        .scrollTargetBehavior(.paging)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    var children: some View {
        nested
        /*
         switch commentTreeMode {
         case .nested:
             nested
         case .paged:
             paged
         }
          */
    }

    var body: some View {
        children
    }
}

#Preview {
    CommentView(Comment(id: "hi", text: "Hello, world"))
}

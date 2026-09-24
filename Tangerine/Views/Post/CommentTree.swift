//
//  CommentTree.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import Defaults
import SwiftUI

struct CommentTree: View {
    private static let colorfulPalette: [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .purple]
    private static let indentBarWidth: CGFloat = 2

    @Default(.commentPalette)
    var commentPalette

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var comments: [Comment]
    var post: Post?
    var depth: Int

    init(_ comments: [Comment], depth: Int = 0, post: Post? = nil) {
        self.comments = comments
        self.post = post
        self.depth = depth
    }

    var indent: CGFloat {
        horizontalSizeClass == .compact ? 10 : 15
    }

    var indentColor: Color {
        switch commentPalette {
        case .minimal: .gray
        case .colorful: Self.colorfulPalette[comments[0].indent % Self.colorfulPalette.count]
        }
    }

    var indentBar: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
            #if os(visionOS)
                .fill(indentColor)
            #else
                .fill(indentColor.opacity(0.5))
            #endif
                .frame(width: Self.indentBarWidth)
                .frame(maxHeight: .infinity)
                .offset(x: -Self.indentBarWidth / 2)
            Spacer()
                .frame(width: indent)
        }
    }

    var body: some View {
        LazyVStack(spacing: .spacingLarge) {
            ForEach(comments) { comment in
                CommentView(comment, post: post)
                if !comment.children.isEmpty {
                    HStack {
                        indentBar
                        CommentTree(comment.children, depth: depth + 1, post: post)
                    }
                    .frame(maxWidth: .infinity)
                }
                if depth == 0 {
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CommentTree(Post.placeholder.comments)
}

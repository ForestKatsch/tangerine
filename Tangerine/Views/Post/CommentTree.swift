//
//  CommentView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import SwiftUI

struct CommentView: View {
    var comment: Comment

    init(_ comment: Comment) {
        self.comment = comment
    }

    var body: some View {
        HNTextView(comment.text ?? "oh no")
            .frame(maxWidth: .infinity, alignment: .leading)
            .border(.red)
    }
}

struct CommentTree: View {
    var comment: Comment

    init(_ comment: Comment) {
        self.comment = comment
    }

    var body: some View {
        HStack {
            Spacer()
                .frame(width: 20 * CGFloat(comment.indent))
            LazyVStack {
                CommentView(comment)
                ForEach(comment.children) { reply in
                    CommentTree(reply)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CommentView(Comment(id: "hi", text: "Hello, world"))
}

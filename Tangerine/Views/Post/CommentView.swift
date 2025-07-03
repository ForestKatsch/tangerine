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

    @State
    var showActionBar = false

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
            Menu { menu } label: {
                Label("post.comment.more", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .frame(width: .icon, height: .icon)
                    .padding(.spacingSmall)
                    .background(Color.clear)
                    .contentShape(RoundedRectangle(cornerRadius: .radius))
            }
        }
        .foregroundStyle(.secondary)
        .font(.subheadline)
    }

    var contents: some View {
        VStack(spacing: .spacingMedium) {
            header
            HNTextView(comment.text ?? "! (Error: no text for this comment)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(comment.id)
        }
    }

    var menu: some View {
        ShareLink(item: comment.hnUrl) {
            Label("share.post.comment.hnUrl", image: "bubble.left.and.bubble.right")
        }
    }

    var actionBar: some View {
        HStack {
            Text("Hello, world")
        }
        .padding()
        .clipShape(Capsule())
        .background(.thickMaterial)
        .padding()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            contents
            /*
                 .onTapGesture {
                     withAnimation {
                         showActionBar.toggle()
                     }
                 }
             if showActionBar {
                 actionBar
             }
              */
        }
        .id(comment.id)
        /*
            .contextMenu {
                menu
                // TODO: - fix. (doesn't properly size the preview :( )
                 } preview: {
                     ZStack(alignment: .topLeading) {
                         contents
                     }
                     .frame(idealWidth: 300, idealHeight: 450)
                     .padding()
                     .background(.background)
            }
         */
    }
}

#Preview {
    CommentView(Comment(id: "hi", text: "Hello, world"))
}

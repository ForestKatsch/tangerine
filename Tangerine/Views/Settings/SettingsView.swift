//
//  SettingsView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/21/24.
//

import Defaults
import SwiftUI

extension CommentTree.Mode {
    var label: LocalizedStringKey {
        switch self {
        case .nested:
            "comment-tree-mode.nested.label"
        case .paged:
            "comment-tree-mode.paged.label"
        }
    }

    var description: LocalizedStringKey {
        switch self {
        case .nested:
            "comment-tree-mode.nested.description"
        case .paged:
            "comment-tree-mode.paged.description"
        }
    }
}

extension CommentTree.IndentPalette {
    var label: LocalizedStringKey {
        switch self {
        case .colorful:
            "comment-palette.colorful.label"
        case .minimal:
            "comment-palette.minimal.label"
        }
    }
}

struct CommentSettings: View {
    @Default(.commentPalette)
    var commentPalette

    @Default(.commentTreeMode)
    var commentTreeMode

    var previewComment: Comment = {
        let start = Comment(id: "a", text: "Blender's binary space partitioned UI layout is a game-changer. Streamlines the workflow tremendously. Anyone else tried it?", authorId: "zlsa")
        let reply = Comment(id: "b", text: "Love how it optimizes screen space, especially on multiple monitors. The customizability is a big plus.", authorId: "RenderRaven")
        let reply2 = Comment(id: "c", text: "Totally agree. Custom layouts make complex projects more manageable. Curious about how it handles custom screens?", authorId: "zlsa")
        let reply3 = Comment(id: "d", text: "It integrates smoothly with custom scripts. The layout adapts dynamically, which is a huge workflow improvement.", authorId: "RenderRaven")

        start.append(comment: reply)
        reply.append(comment: reply2)
        reply2.append(comment: reply3)

        return start
    }()

    var preview: some View {
        CommentTree([previewComment])
            .foregroundStyle(.primary)
    }

    var body: some View {
        Section {
            Picker("comment-palette.label", selection: $commentPalette) {
                ForEach(CommentTree.IndentPalette.allCases) { palette in
                    Text(palette.label)
                        .tag(palette)
                }
            }
            /*
             Picker("comment-tree-mode.label", selection: $commentTreeMode) {
             ForEach(CommentTree.Mode.allCases) { mode in
             Text(mode.label)
             .tag(mode)
             }
             }
             */
        }
        preview
    }
}

extension LinkPreviewMode {
    var label: LocalizedStringKey {
        switch self {
        case .textAndImage:
            "link-preview-mode.text-and-image.label"
        case .textOnly:
            "link-preview-mode.text-only.label"
        case .linkOnly:
            "link-preview-mode.link-only.label"
        }
    }
}

struct PreviewSettings: View {
    @Default(.linkPreviewMode)
    var linkPreviewMode

    var body: some View {
        Section {
            Picker("link-preview-mode.label", selection: $linkPreviewMode) {
                ForEach(LinkPreviewMode.allCases) { mode in
                    Text(mode.label)
                        .tag(mode)
                }
            }
        } header: {} footer: {
            ProminentExternalLink(URL(string: "https://producthunt.com/")!)
                .listRowInsets(.init())
                .padding(.vertical)
            // Text(commentTreeMode.description)
        }
    }
}

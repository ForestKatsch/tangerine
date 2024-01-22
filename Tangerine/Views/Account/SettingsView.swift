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
        let start = Comment(id: "a", text: "I saw your short demo at BarCamp and I must say Dropbox looks great!", authorId: "zlsa")
        let reply = Comment(id: "b", text: "For a Linux user, you can already build such a system yourself quite trivially by getting an FTP account, mounting it locally with curlftpfs, and then using SVN or CVS on the mounted filesystem.", authorId: "RobertJ")
        let reply2 = Comment(id: "c", text: "Many people want something plug and play.", authorId: "dhouston")
        let reply3 = Comment(id: "d", text: "You are correct that this presents a very good, easy-to-install piece of functionality for Windows users.", authorId: "RobertJ")

        start.append(comment: reply)
        reply.append(comment: reply2)
        reply2.append(comment: reply3)

        return start
    }()

    var preview: some View {
        CommentTree([previewComment])
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
        } header: {
            Text("comment-settings.label")
        } footer: {
            preview
                .listRowInsets(.init())
                .padding(.vertical)
        }
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
        } header: {
            Text("link-previews.label")
        } footer: {
            ProminentExternalLink(URL(string: "https://producthunt.com/")!)
                .listRowInsets(.init())
                .padding(.vertical)
            // Text(commentTreeMode.description)
        }
    }
}

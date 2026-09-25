//
//  SettingsScreen.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/5/25.
//

import Defaults
import SwiftUI

struct SettingsPage: View {
    enum Id: Int, CaseIterable, Identifiable {
        case linkPreviews
        case comment

        var id: Self { self }

        var label: LocalizedStringKey {
            switch self {
            case .linkPreviews: "link-previews.label"
            case .comment: "comment-settings.label"
            }
        }

        var systemImage: String {
            switch self {
            case .linkPreviews: "arrow.up.forward.square"
            case .comment: "bubble.left.and.text.bubble.right"
            }
        }
    }

    var page: Id

    var body: some View {
        List {
            switch page {
            case .linkPreviews:
                PreviewSettings()
            case .comment:
                CommentSettings()
            }
        }
        .navigationTitle(page.label)
    }
}

#if os(macOS)
    struct SettingsScreen: View {
        var body: some View {
            TabView {
                ForEach(SettingsPage.Id.allCases) { page in
                    Tab(page.label, systemImage: page.systemImage) {
                        SettingsPage(page: page)
                    }
                }
            }
            .frame(maxWidth: 550, minHeight: 350)
        }
    }
#endif

struct CommentSettings: View {
    private static let previewComment: Comment = {
        let reply3 = Comment(id: "d", text: "It integrates smoothly with custom scripts. The layout adapts dynamically, which is a huge workflow improvement.", authorId: "RenderRaven", indent: 3)
        let reply2 = Comment(id: "c", text: "Totally agree. Custom layouts make complex projects more manageable. Curious about how it handles custom screens?", authorId: "zlsa", indent: 2, children: [reply3])
        let reply = Comment(id: "b", text: "Love how it optimizes screen space, especially on multiple monitors. The customizability is a big plus.", authorId: "RenderRaven", indent: 1, children: [reply2])
        return Comment(id: "a", text: "Blender's binary space partitioned UI layout is a game-changer. Streamlines the workflow tremendously. Anyone else tried it?", authorId: "zlsa", indent: 0, children: [reply])
    }()

    @Default(.commentPalette)
    var commentPalette

    var body: some View {
        Section {
            Picker("comment-palette.label", selection: $commentPalette) {
                ForEach(CommentPalette.allCases) { palette in
                    Text(palette.label)
                        .tag(palette)
                }
            }
            CommentTree([Self.previewComment])
                .foregroundStyle(.primary)
                .allowsHitTesting(false)
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
            ProminentExternalLink(URL(string: "https://spacex.com/")!)
                .allowsHitTesting(false)
        }
    }
}

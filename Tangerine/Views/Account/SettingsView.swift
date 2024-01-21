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

private struct CommentSettings: View {
    @Default(.commentPalette)
    var commentPalette

    @Default(.commentTreeMode)
    var commentTreeMode

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
            Text("Comments")
        } footer: {
            // Text(commentTreeMode.description)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        Form {
            CommentSettings()
        }
        .navigationTitle("settings.title")
    }
}

#Preview {
    SettingsView()
}

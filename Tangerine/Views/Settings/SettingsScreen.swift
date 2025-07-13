//
//  SettingsScreen.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/5/25.
//

import SwiftUI

struct SettingsPage: View {
    enum Id: Int, CaseIterable, Identifiable {
        var id: Self { self }

        case linkPreviews
        case comment

        var label: LocalizedStringKey {
            switch self {
            case .linkPreviews:
                "link-previews.label"
            case .comment:
                "comment-settings.label"
            }
        }

        var systemImage: String {
            switch self {
            case .linkPreviews:
                "arrow.up.forward.square"
            case .comment:
                "bubble.left.and.text.bubble.right"
            }
        }
    }

    var page: Id

    var body: some View {
        VStack {
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

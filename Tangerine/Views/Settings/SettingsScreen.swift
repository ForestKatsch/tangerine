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
        
        case preview
        case comment
        
        var label: LocalizedStringKey {
            switch self {
            case .preview:
                "link-previews.label"
            case .comment:
                "comment-settings.label"
            }
        }
    }

    var page: Id?
    
    var body: some View {
        Form {
            switch page {
            case .preview:
                PreviewSettings()
            case .comment:
                CommentSettings()
            default:
                EmptyView()
            }
        }
        .navigationTitle(page?.label ?? "")
    }
}


struct SettingsScreen: View {
    @State private var selected: SettingsPage.Id = .preview

    var body: some View {
        NavigationSplitView {
            List(SettingsPage.Id.allCases, selection: $selected) { page in
                Text(page.label)
            }
        } detail: {
            SettingsPage(page: selected)
        }
        .navigationTitle("settings.label")
    }
}

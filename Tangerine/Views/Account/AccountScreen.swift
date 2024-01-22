//
//  AccountScreen.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/21/24.
//

import Defaults
import SwiftUI

private enum Page: Int, CaseIterable, Identifiable {
    var id: Self { self }
    case signIn

    case preview
    case comment

    var label: LocalizedStringKey {
        switch self {
        case .signIn:
            "sign-in.label"
        case .preview:
            "link-previews.label"
        case .comment:
            "comment-settings.label"
        }
    }
}

struct SignInView: View {
    var body: some View {
        ContentUnavailableView("account-features.label", systemImage: "person.crop.circle", description: Text("coming-soon.message"))
            .frame(maxWidth: .infinity)
    }
}

private struct PageScreen: View {
    var page: Page?

    var body: some View {
        Form {
            switch page {
            case .signIn:
                SignInView()
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

struct AccountScreen: View {
    var body: some View {
        Form {
            Section {
                SignInView()
            }
            Section("settings.label") {
                NavigationLink(Page.preview.label, value: Page.preview)
                NavigationLink(Page.comment.label, value: Page.comment)
            }
        }
        .navigationTitle("account.label")
        .navigationDestination(for: Page.self) { page in
            PageScreen(page: page)
        }
    }
}

struct AccountColumns: View {
    @State
    private var page: Page? = .preview

    var body: some View {
        NavigationSplitView {
            List(selection: $page) {
                Section {
                    SignInView()
                }
                Section("settings.label") {
                    Text(Page.preview.label)
                        .tag(Page.preview)
                    Text(Page.comment.label)
                        .tag(Page.comment)
                }
            }
            .navigationTitle("account.label")
        } detail: {
            PageScreen(page: page)
        }
    }
}

#Preview {
    AccountScreen()
}

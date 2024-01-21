//
//  ListingScreen.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

extension API.ListingType {
    var name: LocalizedStringKey {
        switch self {
        case .news:
            return "News"
        case .new:
            return "New"
        case .ask:
            return "Ask"
        case .show:
            return "Show"
        case .jobs:
            return "Jobs"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .news:
            return "HN"
        case .ask:
            return "Ask HN"
        case .show:
            return "Show HN"
        default:
            return name
        }
    }

    var systemImage: String {
        switch self {
        case .news:
            return "newspaper"
        case .new:
            return "seal"
        case .ask:
            return "questionmark.circle"
        case .show:
            return "lightbulb"
        case .jobs:
            return "briefcase"
        }
    }
}

struct ListingTypePicker: View {
    @Binding
    var type: API.ListingType

    init(_ type: Binding<API.ListingType>) {
        self._type = type
    }

    var body: some View {
        Picker("Feed", selection: $type) {
            ForEach(API.ListingType.allCases) { type in
                Label(type.name, systemImage: type.systemImage).tag(type)
            }
        }
        #if os(macOS)
        .labelStyle(.titleOnly)
        #endif
    }
}

struct ListingScreen: View {
    @Binding
    var type: API.ListingType

    @Binding
    var selection: Post?

    var api = API.shared

    init(type: Binding<API.ListingType>, selection: Binding<Post?>) {
        self._type = type
        self._selection = selection
    }

    var body: some View {
        InfiniteFetchView(FetchBrowseListing(type: type)) { pages, next, error in
            let posts = pages.flatMap { $0 }
            List(selection: $selection) {
                ForEach(posts, id: \.id) { post in
                    PostRow(post: post, selected: selection == post)
                        .tag(post)
                }
                InfiniteEnd(next: next, error: error)
            }
            .listStyle(.inset)
            .scrollIndicators(.hidden)
        }
        #if !os(visionOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ListingTypePicker($type)
                #if os(macOS)
                    .labelStyle(.titleAndIcon)
                #endif
            }
        }
        #endif
        .navigationTitle(type.title)
    }
}

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
            return "listing.news"
        case .new:
            return "listing.new"
        case .ask:
            return "listing.ask"
        case .show:
            return "listing.show"
        case .jobs:
            return "listing.jobs"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .news:
            return "listing.news.compact"
        case .ask:
            return "listing.ask.compact"
        case .show:
            return "listing.show.compact"
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
        Picker("listing.pick", selection: $type) {
            ForEach(API.ListingType.allCases) { type in
                Label(type.name, systemImage: type.systemImage).tag(type)
            }
        }
        #if os(macOS)
        .labelStyle(.titleOnly)
        #endif
    }
}

struct ListingView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    var type: API.ListingType

    @Binding
    var selection: Post?

    var api = API.shared

    init(type: API.ListingType, selection: Binding<Post?>) {
        self.type = type
        self._selection = selection
    }

    var body: some View {
        InfiniteFetchView(FetchBrowseListing(type: type)) { pages, next, status in
            let posts = pages.flatMap { $0 }
            List(selection: $selection) {
                ForEach(posts, id: \.id) { post in
                    PostRow(post: post)
                        .tag(post)
                }
                InfiniteEnd(next: next, error: status.error)
            }
            #if os(macOS)
            .listStyle(.inset)
            #else
            .listStyle(.insetGrouped)
            #endif
            .scrollIndicators(.hidden)
            .onChange(of: posts.count, initial: true) {
                if posts.isEmpty || selection != nil {
                    return
                }

                let first = posts[0]

                #if os(macOS) || os(visionOS)
                    selection = first
                #endif
                if horizontalSizeClass != .compact {
                    selection = first
                }
            }
        }
        .navigationTitle(type.title)
    }
}

// Navigation-pushing wrapper for ListingView
struct ListingScreen: View {
    let type: API.ListingType
    @State private var selection: Post?

    var body: some View {
        ListingView(type: type, selection: $selection)
            .navigationDestination(item: $selection) { post in
                PostScreen(post)
            }
    }
}

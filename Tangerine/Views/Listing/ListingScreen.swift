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
    }
}

struct ListingScreen: View {
    @State
    var type = API.ListingType.news

    @Binding
    var selected: Item?

    @Binding
    var initial: Item?

    init(selected item: Binding<Item?>, initial: Binding<Item?>) {
        self._selected = item
        self._initial = initial
    }

    var body: some View {
        FetchView(FetchBrowseListing(type: type)) { items in
            List(selection: $selected) {
                ForEach(items, id: \.id) { item in
                    ItemRow(item: item)
                        .tag(item)
                }
            }
            .onAppear {
                initial = items[0]
            }
            #if os(iOS)
            .listStyle(.inset)
            #endif
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ListingTypePicker($type)
                #if os(visionOS) || os(macOS)
                    .labelStyle(.titleAndIcon)
                #endif
            }
        }
        .navigationTitle("HN")
    }
}

#Preview {
    @State
    var selected: Item? = nil

    return NavigationStack {
        ListingScreen(selected: $selected, initial: Binding(get: { nil }, set: { _, _ in }))
    }
}

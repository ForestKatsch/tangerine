//
//  VisionTabRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct TabRoot: View {
    @State
    var post: Post?

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @State
    var accountOpen = false

    @ViewBuilder
    var toolbar: some View {
        Button("account.label", systemImage: "person.crop.circle") {
            accountOpen.toggle()
        }
        .sheet(isPresented: $accountOpen) {
            NavigationStack {
                AccountScreen()
            }
        }
    }

    @ViewBuilder
    var tabs: some View {
        TabView {
            Tab(API.ListingType.news.name, systemImage: API.ListingType.news.systemImage) {
                NavigationStack {
                    ListingScreen(type: API.ListingType.news)
                        .toolbar {
                            toolbar
                        }
                }
            }
            Tab("listing.other", systemImage: "star.hexagon.fill") {
                NavigationStack {
                    ExploreScreen()
                }
            }
        }
    }

    @ViewBuilder
    var columns: some View {
        ListingColumns()
    }

    var body: some View {
        if horizontalSizeClass == .compact {
            tabs
        } else {
            columns
        }
    }
}

#Preview {
    VisionTabRoot()
}

struct ExploreScreen: View {
    @State
    var type: API.ListingType = .show

    var picker: some View {
        Picker("listing.type", selection: $type) {
            ForEach(API.ListingType.allCases.filter { $0 != .news }) { type in
                Label(type.name, systemImage: type.systemImage)
                    .tag(type)
            }
        }
    }

    var body: some View {
        ListingScreen(type: type)
            .toolbar {
                Menu(content: {
                    picker
                        .pickerStyle(.inline)
                }, label: {
                    Image(systemName: type.systemImage)
                })
            }
    }
}

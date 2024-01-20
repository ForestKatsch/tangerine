//
//  TabRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

extension API.ListingType {
    @ViewBuilder
    var view: some View {
        ListingTab(type: self)
            .tag(self)
    }
}

struct TabRoot: View {
    var body: some View {
        TabView {
            ForEach(API.ListingType.allCases) { type in
                type.view
                    .tabItem {
                        Label(type.name, systemImage: type.systemImage)
                    }
            }
        }
    }
}

#Preview {
    TabRoot()
}

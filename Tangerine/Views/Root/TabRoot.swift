//
//  TabRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct TabRoot: View {
    @State
    var post: Post?

    var body: some View {
        TabView {
            ForEach(API.ListingType.allCases) { type in
                ListingColumns(type: type)
                    .tag(type)
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

//
//  VisionTabRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

struct VisionTabRoot: View {
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
            AccountColumns()
                .tag("account")
                .tabItem {
                    Label("account.label", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    VisionTabRoot()
}

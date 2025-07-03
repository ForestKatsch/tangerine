//
//  CopyLink.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/15/23.
//

import SwiftUI

struct OpenLink: View {
    var url: URL
    var label: LocalizedStringKey?

    init(destination url: URL, label: LocalizedStringKey? = nil) {
        self.url = url
        self.label = label
    }

    var body: some View {
        Link(destination: url) {
            Label(label ?? "open.inBrowser", systemImage: "globe")
        }
    }
}

#Preview {
    OpenLink(destination: URL(string: "https://google.com")!)
}

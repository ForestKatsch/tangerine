//
//  CopyLink.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/15/23.
//

import SwiftUI

struct CopyLink: View {
    var url: URL
    var label: LocalizedStringKey?

    init(destination url: URL, label: LocalizedStringKey? = nil) {
        self.url = url
        self.label = label
    }

    var body: some View {
        Button(action: { UIPasteboard.general.url = url }) {
            Label(label ?? "Copy", systemImage: "doc.on.doc")
        }
    }
}

#Preview {
    CopyLink(destination: URL(string: "https://google.com")!)
}

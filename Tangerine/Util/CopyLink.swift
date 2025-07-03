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
        Button(action: copy) {
            Label(label ?? "copy.generic", systemImage: "doc.on.doc")
        }
    }

    func copy() {
        #if canImport(UIKit)
            UIPasteboard.general.url = url
        #endif
    }
}

#Preview {
    CopyLink(destination: URL(string: "https://google.com")!)
}

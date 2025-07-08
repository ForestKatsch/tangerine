//
//  HNTextView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import WebKit
import SwiftUI

struct HNTextView: View {
    var text: String

    init(_ text: String) {
        self.text = text
    }

    func paragraph(_ par: String) -> some View {
        var paragraph = par.trimmingCharacters(in: .whitespacesAndNewlines)
        let mono = paragraph.starts(with: "```")

        if mono {
            paragraph = String(paragraph[paragraph.index(paragraph.startIndex, offsetBy: 3)...])
        }

        if let attributedString = try? AttributedString(markdown: Parse.textToMarkdown(text: String(paragraph))) {
            let text = Text(attributedString)

            return AnyView(
                HStack(alignment: .firstTextBaseline) {
                    if mono {
                        text
                            .font(.body.monospaced())
                    } else {
                        if paragraph.first == ">" {
                            Text(">")
                            text
                        } else {
                            text
                        }
                    }
                }
            )
        }

        return AnyView(EmptyView())
    }

    @State
    var presentingWebView = false

    @State
    var url: URL = .init(string: "https://apple.com/")!
    
    @ViewBuilder
    var copy: some View {
        let paragraphs = text.split(separator: "\n\n")
        VStack(alignment: .leading, spacing: .spacingMedium) {
            ForEach(paragraphs, id: \.self) { par in
                paragraph(String(par))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .textSelection(.enabled)
        }
        .multilineTextAlignment(.leading)
        .font(.body)
        .lineSpacing(4)
    }

    var body: some View {
        copy
            .openLinksInSafari()
    }
}

#Preview {
    HNTextView("Hello, world!\n\n[0] https://google.com\n\n> Hello!")
}

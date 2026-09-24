//
//  HNTextView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import SwiftUI

/// Renders the Markdown produced by ``Parse/hnText(_:)``.
struct HNTextView: View {
    var text: String

    init(_ text: String) {
        self.text = text
    }

    @ViewBuilder
    func paragraph(_ source: String) -> some View {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)
        let mono = trimmed.hasPrefix("```")
        let paragraph = mono ? String(trimmed.dropFirst(3)) : trimmed

        if let markdown = try? AttributedString(markdown: Parse.textToMarkdown(text: paragraph)) {
            HStack(alignment: .firstTextBaseline) {
                if mono {
                    Text(markdown)
                        .font(.body.monospaced())
                } else if paragraph.first == ">" {
                    Text(">")
                    Text(markdown)
                } else {
                    Text(markdown)
                }
            }
        }
    }

    var body: some View {
        if !text.isEmpty {
            VStack(alignment: .leading, spacing: .spacingMedium) {
                ForEach(text.split(separator: "\n\n"), id: \.self) { paragraph in
                    self.paragraph(String(paragraph))
                        .fixedSize(horizontal: false, vertical: true)
                }
                #if !os(tvOS)
                .textSelection(.enabled)
                #endif
            }
            .multilineTextAlignment(.leading)
            .font(.body)
            .lineSpacing(4)
        }
    }
}

#Preview {
    HNTextView("Hello, world!\n\n[0] https://google.com\n\n> Hello!")
}

//
//  HNTextView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import SwiftUI

struct HNTextView: View {
    var text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        let paragraphs = text.split(separator: "\n\n")
        VStack(alignment: .leading, spacing: 15) {
            ForEach(paragraphs, id: \.self) { paragraph in
                if let attributedString = try? AttributedString(markdown: Parse.textToMarkdown(text: String(paragraph))) {
                    Text(attributedString)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .multilineTextAlignment(.leading)
        .font(.body)
        .lineSpacing(3)
    }
}

#Preview {
    HNTextView("Hello, world!\n\n[0] https://google.com")
}

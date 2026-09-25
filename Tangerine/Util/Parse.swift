//
//  Parse.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SwiftSoup

extension Element {
    /// The first element matching `query`.
    func first(_ query: String) -> Element? {
        try? select(query).first()
    }

    /// The text of every element matching `query`; empty, not `nil`, when nothing matches.
    func text(of query: String) -> String? {
        try? select(query).text()
    }

    /// Attribute `key` of the first element matching `query`.
    func attr(_ key: String, of query: String) -> String? {
        try? first(query)?.attr(key)
    }
}

enum Parse {
    static func int(_ string: String) -> Int? {
        Int(string.trimmingCharacters(in: .whitespacesAndNewlines.union(.letters)))
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = .gmt
        return formatter
    }()

    /// Parses the timestamp in an `.age` element's `title`: an ISO date, then a space and a Unix
    /// timestamp.
    static func date(fromSubline string: String) -> Date? {
        dateFormatter.date(from: string.split(separator: " ").first.map(String.init) ?? string)
    }

    private static let bareURL = try? NSRegularExpression(
        pattern: "\\s+(https?://(?:www.)?[-a-zA-Z0-9@:%._+~#=]{1,256}.[a-zA-Z0-9()]{1,6}(?:[-a-zA-Z0-9()@:%_+.~#?&/=]*))",
        options: .caseInsensitive
    )

    /// Turns bare URLs into Markdown links.
    static func textToMarkdown(text: String) -> String {
        bareURL?.stringByReplacingMatches(
            in: text, range: NSRange(text.startIndex..., in: text), withTemplate: "[$0]($0)"
        ) ?? text
    }

    /// Flattens an HN text block into Markdown paragraphs separated by blank lines.
    ///
    /// HN's markup is loose: the first paragraph is a bare text node and only the rest get a
    /// `<p>`, code comes as `<pre>`, and comments carry their reply link inside the text:
    ///
    ///     <div class="commtext c00">
    ///       My first paragraph.
    ///       <p>My second paragraph.</p>
    ///       <pre><code>  let x = 1</code></pre>
    ///       <div class="reply">...</div>
    ///     </div>
    ///
    /// A code block is a paragraph starting with "```".
    static func hnText(_ element: Element) -> String {
        var paragraphs: [String] = []
        var paragraph = ""

        func endParagraph() {
            let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                paragraphs.append(trimmed)
            }
            paragraph = ""
        }

        for node in element.getChildNodes() {
            guard let child = node as? Element else {
                paragraph += (node as? TextNode)?.text() ?? ""
                continue
            }

            switch child.tagName() {
            case "p":
                endParagraph()
                paragraph = inline(child)
            case "pre":
                endParagraph()
                paragraph = "```\n" + inline(child)
                endParagraph()
            case "div" where child.hasClass("reply"):
                continue
            default:
                paragraph += inline(child)
            }
        }

        endParagraph()

        return paragraphs.joined(separator: "\n\n")
    }

    /// The Markdown for an element's inline contents: text, links, italics and code.
    private static func inline(_ element: Element) -> String {
        element.getChildNodes().map { node in
            guard let child = node as? Element else {
                return (node as? TextNode)?.text() ?? ""
            }

            switch child.tagName() {
            case "code":
                return inline(child).trimmingCharacters(in: .whitespaces)
            case "a":
                guard let href = try? child.attr("href"), let text = try? child.text() else {
                    return ""
                }
                return "[\(text)](\(href))"
            case "i":
                return "_\(inline(child))_"
            case let name:
                return "`unknown tag <\(name)>`"
            }
        }
        .joined()
    }
}

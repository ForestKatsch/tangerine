//
//  Parse.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SwiftSoup

enum Parse {
    static func int(_ string: String) -> Int? {
        Int(string.trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet.letters)))
    }

    // Parses HN's date format.
    static func date(fromSubline string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = .gmt
        let datePart = string.split(separator: " ").first.map(String.init) ?? string
        return dateFormatter.date(from: datePart)
    }

    static func textToMarkdown(text: String) -> String {
        if let regex = try? NSRegularExpression(pattern: "\\s+(https?://(?:www.)?[-a-zA-Z0-9@:%._+~#=]{1,256}.[a-zA-Z0-9()]{1,6}(?:[-a-zA-Z0-9()@:%_+.~#?&/=]*))", options: .caseInsensitive) {
            return regex.stringByReplacingMatches(in: text, range: NSRange(text.startIndex..., in: text), withTemplate: "[$0]($0)")
        }

        return text
    }

    static func parseHNText(blockElement element: Element) throws -> String {
        var p = ""

        for node in element.getChildNodes() {
            if let node = node as? TextNode {
                p += node.text()
                continue
            }

            guard let element = node as? Element else {
                continue
            }

            let name = element.tagName()

            if name == "code" {
                if let text = try? parseHNText(blockElement: element) {
                    p += text.trimmingCharacters(in: .whitespaces)
                }
            } else if name == "a" {
                if let href = try? element.attr("href"), let text = try? element.text() {
                    p += "[\(text)](\(href))"
                }
            } else if name == "i" {
                if let contents = try? parseHNText(blockElement: element) {
                    p += "_" + contents + "_"
                }
            } else {
                p += "`unknown tag <\(name)>`"
            }
        }

        return p
    }

    static func parseHNText(text element: Element) throws -> [String] {
        // Weird fuckery is needed because HN's formatting is insane:
        //
        // <div id="container">
        //   My first paragraph.
        //   <p>My second paragraph.</p>
        //   <p>My third paragraph.</p>
        // </div>

        // And for comments:
        //
        // <div class="comment">
        //   <span class="commtext c00">
        //     My first paragraph
        //     <p>My second paragraph.</p>
        //     <p>My third paragraph.</p>
        //     <div class="reply">...</div> <!-- wtf -->
        //   </span>
        // </div>

        var p = ""

        var paragraphs: [String] = []

        func appendParagraph() {
            if p.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return
            }

            paragraphs.append(p.trimmingCharacters(in: .whitespacesAndNewlines))
            p = ""
        }

        for node in element.getChildNodes() {
            if let node = node as? TextNode {
                p += node.text()
                continue
            }

            guard let element = node as? Element else {
                continue
            }

            let name = element.tagName()
            if name == "p" {
                appendParagraph()
                if let paragraph = try? parseHNText(blockElement: element) {
                    p += paragraph
                } else {
                    throw TangerineError.generic(.cannotParseHtml, context: "p")
                }
            } else if name == "span", element.hasClass("commtext") {
                if let paragraph = try? parseHNText(blockElement: element) {
                    p += paragraph
                } else {
                    throw TangerineError.generic(.cannotParseHtml, context: "span commtext")
                }
            } else if name == "pre" {
                if let paragraph = try? parseHNText(blockElement: element) {
                    appendParagraph()
                    p = "```\n" + paragraph
                    appendParagraph()
                } else {
                    throw TangerineError.generic(.cannotParseHtml, context: "pre")
                }
            } else if name == "div", element.hasClass("reply") {
                continue
            } else {
                p += (try? parseHNText(blockElement: element)) ?? ""
            }
        }

        appendParagraph()

        return paragraphs
    }
}

//
//  FetchBrowseListing.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import OSLog
import SwiftSoup

private let l = Logger(category: "API+Listing")

/// Mutable scratch node used while reconstructing the comment tree from HN's flat, indent-tagged
/// comment list. Frozen into an immutable ``Comment`` once its whole subtree is parsed.
private final class CommentNode {
    let id: String
    let indent: Int

    var authorId: String?
    var postedDate: Date?
    var score: Int?
    var text: String?
    var children: [CommentNode] = []

    init(id: String, indent: Int) {
        self.id = id
        self.indent = indent
    }

    func freeze() -> Comment {
        Comment(
            id: id, text: text, score: score, authorId: authorId, postedDate: postedDate,
            indent: indent, children: children.map { $0.freeze() }
        )
    }
}

extension Post {
    static func parse(fromPostPage document: Document, postId: String, url _: URL? = nil) throws -> Post {
        try? API.shared.parse(document)

        guard let main = try? document.select("#hnmain").first() else {
            throw TangerineError.generic(.cannotParseHtml, context: "#hnmain")
        }

        guard let postContainer = try? main.select("> tbody table.fatitem").first() else {
            throw TangerineError.generic(.cannotParseHtml, context: ".fatitem")
        }

        var postText: String?
        if let textContainer = try? postContainer.select("div.toptext").first() {
            postText = try? Parse.parseHNText(text: textContainer).joined(separator: "\n\n")
        }

        // Ugh, comment parsing lol.
        guard let commentContainer = try? main.select("table.comment-tree > tbody").first() else {
            return Post(id: postId, text: postText)
        }

        guard let commentElements = try? commentContainer.select("> tr.athing") else {
            return Post(id: postId, text: postText)
        }

        var topLevel: [CommentNode] = []
        var commentBranch: [CommentNode] = []

        for element in commentElements {
            guard let indentString = try? element.select("td.ind[indent]").first()?.attr("indent") else {
                l.error("oh no - expected indent!")
                continue
            }

            guard let indent = Int(indentString, radix: 10) else {
                l.error("oh no - expected indent 2.0!")
                continue
            }

            let comment = CommentNode(id: element.id(), indent: indent)

            if indent == commentBranch.count {
                // One deeper!
                // A <-- branch.count == 1
                //   B <-- comment: indent = 1
            } else if indent == commentBranch.count - 1 {
                // Sibling of current
                // A
                //   B <-- branch.count == 2
                //   C <-- comment: indent = 1
                _ = commentBranch.popLast()
            } else if indent < commentBranch.count {
                // Back to a previous parent!
                // A
                //   B <-- branch.count == 2
                // C <-- comment: indent = 0
                commentBranch.removeLast(commentBranch.count - indent)
            } else {
                l.error("oh shit we lost our spot")
            }

            // Nothing on the branch - therefore we are a parent.
            if let parent = commentBranch.last {
                parent.children.append(comment)
            } else {
                topLevel.append(comment)
            }

            commentBranch.append(comment)

            // OK, let's fill out the comment.
            if let header = try? element.select("span.comhead").first() {
                if let authorText = try? header.select(".hnuser").text() {
                    comment.authorId = authorText
                } else {
                    l.warning("could not find header '.hnuser' for comment \(comment.id)")
                }

                if let age = try? header.select(".age").first() {
                    if let postedDate = try? age.attr("title") {
                        comment.postedDate = Parse.date(fromSubline: postedDate)
                    }
                } else {
                    l.warning("could not find header '.age' for comment \(comment.id)")
                }
            }

            if let textElement = try? element.select("div.comment > .commtext").first() {
                comment.score = try? Comment.parseScore(fromComment: textElement)
                comment.text = try? Parse.parseHNText(text: textElement).joined(separator: "\n\n")
            }
        }

        return Post(id: postId, text: postText, comments: topLevel.map { $0.freeze() })
    }
}

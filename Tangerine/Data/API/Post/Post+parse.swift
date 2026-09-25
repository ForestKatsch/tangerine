//
//  Post+parse.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import OSLog
import SwiftSoup

private let l = Logger(category: "API+Post")

extension Post {
    static func parse(fromPostPage document: Document, postId: String) throws -> Post {
        guard let main = document.first("#hnmain") else {
            throw TangerineError.generic(.cannotParseHtml, context: "#hnmain")
        }

        guard let postContainer = main.first("> tbody table.fatitem") else {
            throw TangerineError.generic(.cannotParseHtml, context: ".fatitem")
        }

        // HN emits the comment tree on every item page, empty ones included — a post with no
        // replies still gets a bare `<table class="comment-tree"></table>`. So a missing table
        // means we were handed a page we don't understand, and that's an error: returning an empty
        // post instead would be indistinguishable from a post nobody has replied to.
        guard let commentContainer = main.first("table.comment-tree") else {
            throw TangerineError.generic(.cannotParseHtml, context: ".comment-tree")
        }

        // Rows are direct children of the table's implied `tbody`, which the HTML parser only
        // synthesizes once there's at least one row — hence matching the table, not its `tbody`,
        // above. No rows is a legitimately empty result, not a failure.
        let rows = try commentContainer.select("> tbody > tr.athing")

        return Post(
            id: postId,
            text: postContainer.first("div.toptext").map(Parse.hnText),
            comments: tree(from: rows.compactMap(parse(commentRow:)))
        )
    }

    /// One comment, without its replies.
    private static func parse(commentRow row: Element) -> Comment? {
        guard let indent = row.attr("indent", of: "td.ind[indent]").flatMap({ Int($0) }) else {
            l.error("comment \(row.id()) has no indent")
            return nil
        }

        let header = row.first("span.comhead")
        let body = row.first("div.comment > .commtext")

        return Comment(
            id: row.id(),
            text: body.map(Parse.hnText),
            score: body.flatMap(Comment.score(fromClassesOf:)),
            authorId: header?.text(of: ".hnuser"),
            postedDate: header?.attr("title", of: ".age").flatMap(Parse.date(fromSubline:)),
            indent: indent
        )
    }

    /// HN sends comments as a flat list, each tagged with its depth. Rebuild the tree by keeping the
    /// chain of open ancestors: a comment at depth `n` is a reply to the `n`th one.
    private static func tree(from comments: [Comment]) -> [Comment] {
        var roots: [CommentNode] = []
        var branch: [CommentNode] = []

        for comment in comments {
            if comment.indent <= branch.count {
                branch.removeLast(branch.count - comment.indent)
            } else {
                l.error("comment \(comment.id) is nested deeper than its parent")
            }

            let node = CommentNode(comment)

            if let parent = branch.last {
                parent.replies.append(node)
            } else {
                roots.append(node)
            }

            branch.append(node)
        }

        return roots.map(\.frozen)
    }
}

/// Mutable scratch node used while rebuilding the comment tree, frozen into an immutable
/// ``Comment`` once its whole subtree is known.
private final class CommentNode {
    let comment: Comment
    var replies: [CommentNode] = []

    init(_ comment: Comment) {
        self.comment = comment
    }

    var frozen: Comment {
        comment.with(children: replies.map(\.frozen))
    }
}

extension Comment {
    /// HN fades out downvoted comments with a `cXX` class, `c00` (untouched) through `cdd`
    /// (faintest); read that back as a score from 0 down to -7.
    static func score(fromClassesOf element: Element) -> Int? {
        guard let classes = try? element.classNames(),
              let shade = classes.first(where: { $0.count == 3 && $0.hasPrefix("c") && $0.dropFirst().allSatisfy(\.isHexDigit) }),
              let value = Int(shade.dropFirst(), radix: 16)
        else {
            return nil
        }

        return -(min(value, 0xdd) / 0x1d)
    }
}

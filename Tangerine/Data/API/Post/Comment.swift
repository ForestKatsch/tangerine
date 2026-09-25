//
//  Comment.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import Foundation

final class Comment: Identifiable, Hashable, Sendable {
    let id: String
    let text: String?
    let score: Int?
    let authorId: String?
    let postedDate: Date?

    /// Nesting depth, taken straight from the parsed HTML (`td.ind[indent]`).
    let indent: Int
    let children: [Comment]

    init(
        id: String, text: String? = nil, score: Int? = nil,
        authorId: String? = nil, postedDate: Date? = nil,
        indent: Int = 0, children: [Comment] = []
    ) {
        self.id = id
        self.text = text
        self.score = score
        self.authorId = authorId
        self.postedDate = postedDate
        self.indent = indent
        self.children = children
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (a: Comment, b: Comment) -> Bool {
        a.id == b.id
    }

    func with(children: [Comment]) -> Comment {
        Comment(
            id: id, text: text, score: score, authorId: authorId, postedDate: postedDate,
            indent: indent, children: children
        )
    }

    var hnUrl: URL {
        API.itemURL(id: id)
    }

    /// Downvoted comments fade out, down to 10% at a score of -9.
    var opacity: CGFloat {
        guard let score, score < 0 else {
            return 1
        }

        return 1 - CGFloat(min(-score, 9)) / 9 * 0.9
    }
}

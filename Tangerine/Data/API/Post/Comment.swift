//
//  Comment.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import Foundation

final class Comment: Identifiable, Hashable, Sendable {
    init(
        id: String, text: String? = nil, score: Int? = nil,
        authorId: String? = nil, postedDate: Date? = nil,
        indent: Int = 0, isPlaceholder: Bool = false, children: [Comment] = []
    ) {
        self.id = id
        self.text = text
        self.score = score
        self.authorId = authorId
        self.postedDate = postedDate
        self.indent = indent
        self.isPlaceholder = isPlaceholder
        self.children = children
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (a: Comment, b: Comment) -> Bool {
        a.id == b.id
    }

    let id: String

    let text: String?

    let score: Int?

    let authorId: String?
    let postedDate: Date?

    let isPlaceholder: Bool

    /// Nesting depth, taken straight from the parsed HTML (`td.ind[indent]`).
    let indent: Int
    let children: [Comment]

    var hnUrl: URL {
        URL(string: "https://news.ycombinator.com/item?id=\(id)")!
    }
}

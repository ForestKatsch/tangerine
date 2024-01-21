//
//  Comment.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import Foundation

@Observable
class Comment: Identifiable, Hashable {
    init(
        id: String, text: String? = nil, score: Int? = nil,
        authorId: String? = nil, postedDate: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.score = score
        self.authorId = authorId
        self.postedDate = postedDate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (a: Comment, b: Comment) -> Bool {
        a.id == b.id
    }

    var id: String

    var text: String?

    var score: Int?

    var authorId: String?
    var postedDate: Date?

    var isPlaceholder = false

    var children: [Comment] = []

    var hnUrl: URL {
        URL(string: "https://news.ycombinator.com/item?id=\(id)")!
    }
}

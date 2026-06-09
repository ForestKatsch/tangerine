//
//  Post.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SwiftUI

enum Vote {
    case up
    case down
}

final class Post: Identifiable, Hashable, Sendable {
    init(
        id: String, title: String? = nil, link: URL? = nil, text: String? = nil, score: Int? = nil,
        authorId: String? = nil, postedDate: Date? = nil, commentCount: Int? = nil,
        kind: Post.Kind? = nil, comments: [Comment] = []
    ) {
        self.id = id
        self.title = title
        self.link = link
        self.text = text
        self.score = score
        self.authorId = authorId
        self.postedDate = postedDate
        self.commentCount = commentCount
        self.kind = kind
        self.comments = comments
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (a: Post, b: Post) -> Bool {
        a.id == b.id
    }

    let id: String
    let title: String?

    let link: URL?
    let text: String?

    let score: Int?

    let authorId: String?
    let postedDate: Date?

    let commentCount: Int?

    let kind: Kind?

    let comments: [Comment]

    var hnUrl: URL {
        URL(string: "https://news.ycombinator.com/item?id=\(id)")!
    }

    var likelyToContainText: Bool {
        kind != .job && link == nil
    }

    enum Kind: Identifiable, CaseIterable {
        var id: Self { self }

        case normal
        case job

        var name: LocalizedStringKey {
            switch self {
            case .normal:
                return "post.kind.normal"
            case .job:
                return "post.kind.job"
            }
        }

        var systemImage: String {
            switch self {
            case .normal:
                return "link"
            case .job:
                return "briefcase.fill"
            }
        }
    }

    static var placeholder: Post {
        let childComment = Comment(
            id: UUID().uuidString, text: "Hello, world!", authorId: "joseph", indent: 1
        )
        let topComment = Comment(
            id: UUID().uuidString, text: "First", authorId: "zlsa", indent: 0,
            children: [childComment]
        )
        return Post(
            id: UUID().uuidString, title: "Show HN: Tangerine for Hacker News open-source iOS app",
            link: URL(string: "https://forestkatsch.com/"), score: 128, authorId: "zlsa",
            commentCount: 32, kind: .normal, comments: [topComment]
        )
    }

    /// Combine the listing post (identity, title, score) with a freshly fetched post's body and
    /// comments. Returns a new immutable `Post`; `self` is returned unchanged if the ids differ.
    func merge(from: Post) -> Post {
        guard from == self else {
            return self
        }

        return Post(
            id: id, title: title, link: link, text: from.text, score: score,
            authorId: authorId, postedDate: postedDate, commentCount: commentCount,
            kind: kind, comments: from.comments
        )
    }
}

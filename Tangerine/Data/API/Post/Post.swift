//
//  Post.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SwiftUI

final class Post: Identifiable, Hashable, Sendable {
    enum Kind {
        case normal
        case job

        var name: LocalizedStringKey {
            switch self {
            case .normal: "post.kind.normal"
            case .job: "post.kind.job"
            }
        }

        var systemImage: String {
            switch self {
            case .normal: "link"
            case .job: "briefcase.fill"
            }
        }
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

    init(
        id: String, title: String? = nil, link: URL? = nil, text: String? = nil, score: Int? = nil,
        authorId: String? = nil, postedDate: Date? = nil, commentCount: Int? = nil,
        kind: Kind? = nil, comments: [Comment] = []
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

    var hnUrl: URL {
        API.itemURL(id: id)
    }

    var likelyToContainText: Bool {
        kind != .job && link == nil
    }

    /// Combine the listing post (identity, title, score) with a freshly fetched post's body and
    /// comments. Returns a new immutable `Post`; `self` is returned unchanged if the ids differ.
    func merge(from fetched: Post) -> Post {
        guard fetched == self else {
            return self
        }

        return Post(
            id: id, title: title, link: link, text: fetched.text, score: score,
            authorId: authorId, postedDate: postedDate, commentCount: commentCount,
            kind: kind, comments: fetched.comments
        )
    }

    static var placeholder: Post {
        let reply = Comment(id: UUID().uuidString, text: "Hello, world!", authorId: "joseph", indent: 1)
        let comment = Comment(id: UUID().uuidString, text: "First", authorId: "zlsa", indent: 0, children: [reply])

        return Post(
            id: UUID().uuidString, title: "Show HN: Tangerine for Hacker News open-source iOS app",
            link: URL(string: "https://forestkatsch.com/"), score: 128, authorId: "zlsa",
            commentCount: 32, kind: .normal, comments: [comment]
        )
    }
}

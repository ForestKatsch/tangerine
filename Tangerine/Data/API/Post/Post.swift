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

@Observable
class Post: Identifiable, Hashable {
    init(
        id: String, title: String? = nil, link: URL? = nil, text: String? = nil, score: Int? = nil,
        authorId: String? = nil, postedDate: Date? = nil, commentCount: Int? = nil,
        kind: Post.Kind? = nil
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
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (a: Post, b: Post) -> Bool {
        a.id == b.id
    }

    var id: String
    var title: String?

    var link: URL?
    var text: String?

    var score: Int?

    var authorId: String?
    var postedDate: Date?

    var commentCount: Int?

    var kind: Kind?

    var comments: [Comment] = []

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
        let post = Post(
            id: UUID().uuidString, title: "Show HN: Tangerine for Hacker News open-source iOS app",
            link: URL(string: "https://forestkatsch.com/"), score: 128, authorId: "zlsa",
            commentCount: 32, kind: .normal
        )
        let topComment = Comment(id: UUID().uuidString, text: "First", authorId: "zlsa")
        let childComment = Comment(id: UUID().uuidString, text: "Hello, world!", authorId: "joseph")
        topComment.children.append(childComment)
        childComment.parent = topComment

        post.comments.append(topComment)
        return post
    }

    func canVote(_: Vote) {}

    func vote(_ vote: Vote) {
        if vote == .up {
            score? += 1
        } else {
            score? -= 1
        }
        // TODO: upvote/downvote event
    }

    func merge(from: Post) -> Post {
        if from != self {
            return self
        }

        text = from.text
        comments = from.comments
        return self
    }
}

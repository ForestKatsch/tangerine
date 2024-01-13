//
//  Item.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SwiftUI

class Item: Identifiable, Hashable {
    init(id: String, title: String? = nil, link: URL? = nil, text: String? = nil, score: Int? = nil, authorId: String? = nil, postedDate: Date? = nil, commentCount: Int? = nil, kind: Item.Kind? = nil) {
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

    static func == (a: Item, b: Item) -> Bool {
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

    var hnUrl: URL {
        URL(string: "https://news.ycombinator.com/item?id=\(id)")!
    }

    enum Kind: Identifiable, CaseIterable {
        var id: Self { self }

        case normal
        case job

        var systemImage: String {
            switch self {
            case .normal:
                return "link"
            case .job:
                return "briefcase"
            }
        }
    }

    static var placeholder: Item {
        Item(id: UUID().uuidString, title: "Show HN: Tangerine for Hacker News open-source iOS app", score: 128, authorId: "zlsa", postedDate: Date(), commentCount: 32, kind: .normal)
    }
}

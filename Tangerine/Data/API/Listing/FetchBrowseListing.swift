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

extension API.ListingType {
    var url: URL? {
        switch self {
        case .news:
            return URL(string: "https://news.ycombinator.com/news")
        case .new:
            return URL(string: "https://news.ycombinator.com/newest")
        case .ask:
            return URL(string: "https://news.ycombinator.com/ask")
        case .show:
            return URL(string: "https://news.ycombinator.com/show")
        case .jobs:
            return URL(string: "https://news.ycombinator.com/jobs")
        }
    }
}

extension API {
    static func urlFor(listingType type: ListingType) -> URL? {
        return type.url
    }
}

extension Item {
    static func parse(fromListingPage document: Document, url: URL? = nil, listingType type: API.ListingType? = nil) throws -> [Item] {
        try? API.shared.parse(document)

        guard let main = try? document.select("#hnmain").first() else {
            throw TangerineError.generic(.cannotParseHtml, context: "#hnmain")
        }

        guard let listingContainer = try? main.select("> tbody > tr#pagespace + tr table").first() else {
            throw TangerineError.generic(.cannotParseHtml, context: "listing container")
        }

        guard let itemElements = try? listingContainer.select(".athing") else {
            throw TangerineError.generic(.cannotParseHtml, context: "listing items")
        }

        var items: [Item] = []

        for element in itemElements.array() {
            let item = Item(id: element.id())

            item.kind = type == .jobs ? .job : .normal

            if let titleLine = try? element.select(".titleline").first() {
                if let link = try? titleLine.select("a").first() {
                    if let linkUrl = try? link.attr("href") {
                        item.link = URL(string: linkUrl, relativeTo: url)
                    }
                }

                if let title = try? titleLine.select("a").first()?.text() {
                    item.title = title
                }
            }

            if let footer = try? element.nextElementSibling()?.select(".subtext").first() {
                if let scoreText = try? footer.select(".score").text() {
                    item.score = Parse.int(scoreText)
                } else {
                    l.warning("could not find footer '.score' for item \(item.id)")
                }

                if let authorText = try? footer.select(".hnuser").text() {
                    item.authorId = authorText
                } else {
                    l.warning("could not find footer '.hnuser' for item \(item.id)")
                }

                if let age = try? footer.select(".age").first() {
                    if let postedDate = try? age.attr("title") {
                        item.postedDate = Parse.date(fromSubline: postedDate)
                    }
                } else {
                    l.warning("could not find footer '.age' for item \(item.id)")
                }

                if let commentCountText = try? footer.select("a[href^=item]").last()?.text() {
                    if commentCountText.hasSuffix("discuss") {
                        item.commentCount = 0
                    } else if commentCountText.hasSuffix("comment") || commentCountText.hasSuffix("comments") {
                        item.commentCount = Parse.int(commentCountText)
                    }
                } else {
                    l.warning("could not find footer '.score' for item \(item.id)")
                }

                if let hideElement = try? footer.select("a[href^=hide]").first() {
                    if (try? hideElement.nextElementSibling()) == nil {
                        item.kind = .job
                    }
                }
            } else {
                l.warning("could not find sibling '.subtext' for item \(item.id) - most fields will be nil")
            }

            items.append(item)
        }

        return items
    }
}

struct FetchBrowseListing: Fetchable {
    typealias T = [Item]
    typealias P = Int

    static var placeholder: [Item]? = nil // Item.placeholder(list: 20)

    var type: API.ListingType

    var url: URL? { API.urlFor(listingType: type) }

    init(type: API.ListingType) {
        self.type = type
    }

    func fetch() async throws -> [Item] {
        guard let url = url else {
            throw TangerineError.generic(.cannotCreateUrl)
        }

        let request = URLRequest(url: url)
        return try Item.parse(fromListingPage: await API.shared.fetchHTML(for: request), url: url, listingType: type)
    }
}

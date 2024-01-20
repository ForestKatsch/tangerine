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
    static func urlFor(listingType type: ListingType, page: Int? = nil) -> URL? {
        var url = type.url

        if let page {
            url?.append(queryItems: [
                .init(name: "p", value: String(page + 1)),
            ])
        }
        return url
    }
}

extension Post {
    static func parse(fromListingPage document: Document, url: URL? = nil, listingType type: API.ListingType? = nil) throws -> [Post] {
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

        var posts: [Post] = []

        for element in itemElements.array() {
            let post = Post(id: element.id())

            post.kind = type == .jobs ? .job : .normal

            if let titleLine = try? element.select(".titleline").first() {
                if let link = try? titleLine.select("a").first() {
                    if let linkUrl = try? link.attr("href") {
                        post.link = URL(string: linkUrl, relativeTo: url)
                    }
                }

                if let title = try? titleLine.select("a").first()?.text() {
                    post.title = title
                }
            }

            if let footer = try? element.nextElementSibling()?.select(".subtext").first() {
                if let scoreText = try? footer.select(".score").text() {
                    post.score = Parse.int(scoreText)
                } else {
                    l.warning("could not find footer '.score' for post \(post.id)")
                }

                if let authorText = try? footer.select(".hnuser").text() {
                    post.authorId = authorText
                } else {
                    l.warning("could not find footer '.hnuser' for post \(post.id)")
                }

                if let age = try? footer.select(".age").first() {
                    if let postedDate = try? age.attr("title") {
                        post.postedDate = Parse.date(fromSubline: postedDate)
                    }
                } else {
                    l.warning("could not find footer '.age' for post \(post.id)")
                }

                // If the comment URL and link URL go to the same URL, it's a text post!
                if let commentUrl = try? footer.select("a[href^=item]").last()?.attr("href") {
                    if let commentUrl = URL(string: commentUrl, relativeTo: url) {
                        if commentUrl == post.link {
                            post.link = nil
                        }
                    }
                }
                if let commentCountText = try? footer.select("a[href^=item]").last()?.text() {
                    if commentCountText.hasSuffix("discuss") {
                        post.commentCount = 0
                    } else if commentCountText.hasSuffix("comment") || commentCountText.hasSuffix("comments") {
                        post.commentCount = Parse.int(commentCountText)
                    }
                } else {
                    l.warning("could not find footer '.score' for post \(post.id)")
                }

                if let hideElement = try? footer.select("a[href^=hide]").first() {
                    if (try? hideElement.nextElementSibling()) == nil {
                        post.kind = .job
                    }
                }
            } else {
                l.warning("could not find sibling '.subtext' for post \(post.id) - most fields will be nil")
            }

            posts.append(post)
        }

        return posts
    }
}

struct FetchBrowseListing: InfiniteFetchable {
    typealias T = [Post]
    typealias P = Int

    static var placeholder: [Post]? = Post.placeholder(list: 20)

    var type: API.ListingType

    init(type: API.ListingType) {
        self.type = type
    }

    func fetch(page: Int?) async throws -> ([Post], Int) {
        guard let url = API.urlFor(listingType: type, page: page) else {
            throw TangerineError.generic(.cannotCreateUrl)
        }

        let request = URLRequest(url: url)

        return try (
            Post.parse(fromListingPage: await API.shared.fetchHTML(for: request), url: url, listingType: type),
            (page ?? 0) + 1
        )
    }
}

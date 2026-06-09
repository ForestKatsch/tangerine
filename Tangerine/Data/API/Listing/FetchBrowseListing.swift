//
//  FetchBrowseListing.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Aquifer
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

        guard let listingContainer = try? main.select("tbody > tr#bigbox table tbody").first() else {
            throw TangerineError.generic(.cannotParseHtml, context: "listing container")
        }

        guard let itemElements = try? listingContainer.select(".athing") else {
            throw TangerineError.generic(.cannotParseHtml, context: "listing items")
        }

        var posts: [Post] = []

        for element in itemElements.array() {
            let id = element.id()

            var kind: Post.Kind = type == .jobs ? .job : .normal
            var link: URL?
            var title: String?
            var score: Int?
            var authorId: String?
            var postedDate: Date?
            var commentCount: Int?

            if let titleLine = try? element.select(".titleline").first() {
                if let linkElement = try? titleLine.select("a").first() {
                    if let linkUrl = try? linkElement.attr("href") {
                        link = URL(string: linkUrl, relativeTo: url)
                    }
                }

                if let titleText = try? titleLine.select("a").first()?.text() {
                    title = titleText
                }
            }

            if let footer = try? element.nextElementSibling()?.select(".subtext").first() {
                if let scoreText = try? footer.select(".score").text() {
                    score = Parse.int(scoreText)
                } else {
                    l.warning("could not find footer '.score' for post \(id)")
                }

                if let authorText = try? footer.select(".hnuser").text() {
                    authorId = authorText
                } else {
                    l.warning("could not find footer '.hnuser' for post \(id)")
                }

                if let age = try? footer.select(".age").first() {
                    if let postedDateText = try? age.attr("title") {
                        postedDate = Parse.date(fromSubline: postedDateText)
                    }
                } else {
                    l.warning("could not find footer '.age' for post \(id)")
                }

                // If the comment URL and link URL go to the same URL, it's a text post!
                if let commentUrl = try? footer.select("a[href^=item]").last()?.attr("href") {
                    if let commentUrl = URL(string: commentUrl, relativeTo: url) {
                        if commentUrl == link {
                            link = nil
                        }
                    }
                }
                if let commentCountText = try? footer.select("a[href^=item]").last()?.text() {
                    if commentCountText.hasSuffix("discuss") {
                        commentCount = 0
                    } else if commentCountText.hasSuffix("comment") || commentCountText.hasSuffix("comments") {
                        commentCount = Parse.int(commentCountText)
                    }
                } else {
                    l.warning("could not find footer '.score' for post \(id)")
                }

                if let hideElement = try? footer.select("a[href^=hide]").first() {
                    if (try? hideElement.nextElementSibling()) == nil {
                        kind = .job
                    }
                }
            } else {
                l.warning("could not find sibling '.subtext' for post \(id) - most fields will be nil")
            }

            posts.append(Post(
                id: id, title: title, link: link, score: score, authorId: authorId,
                postedDate: postedDate, commentCount: commentCount, kind: kind
            ))
        }

        if posts.isEmpty {
            throw TangerineError.noMoreResults
        }

        return posts
    }
}

struct FetchBrowseListing: InfiniteQuery {
    typealias Page = [Post]
    typealias PageParam = Int

    let type: API.ListingType

    var initialPageParam: Int { 0 }

    func fetch(page param: Int) async throws -> [Post] {
        guard let url = API.urlFor(listingType: type, page: param) else {
            throw TangerineError.generic(.cannotCreateUrl)
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringCacheData

        return try Post.parse(
            fromListingPage: await API.shared.fetchHTML(for: request), url: url, listingType: type
        )
    }

    // Forward-only: as long as the last page returned posts, assume there's another. A page that
    // comes back empty (HN throws `noMoreResults` first, surfaced as the footer error) ends it.
    func nextPageParam(after last: [Post], pages _: [[Post]], params: [Int]) -> Int? {
        last.isEmpty ? nil : (params.last ?? 0) + 1
    }
}

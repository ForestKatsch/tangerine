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
    var url: URL {
        let path = self == .new ? "newest" : rawValue
        return URL(string: "https://news.ycombinator.com/\(path)")!
    }

    /// `page` counts from zero; HN's `p` counts from one.
    func url(page: Int) -> URL {
        url.appending(queryItems: [URLQueryItem(name: "p", value: String(page + 1))])
    }
}

extension Post {
    static func parse(fromListingPage document: Document, url: URL? = nil, listingType type: API.ListingType? = nil) throws -> [Post] {
        guard let main = document.first("#hnmain") else {
            throw TangerineError.generic(.cannotParseHtml, context: "#hnmain")
        }

        guard let container = main.first("tbody > tr#bigbox table tbody") else {
            throw TangerineError.generic(.cannotParseHtml, context: "listing container")
        }

        guard let items = try? container.select(".athing") else {
            throw TangerineError.generic(.cannotParseHtml, context: "listing items")
        }

        let posts = items.map { parse(listingItem: $0, url: url, type: type) }

        if posts.isEmpty {
            throw TangerineError.noMoreResults
        }

        return posts
    }

    /// One listing entry: a `.athing` row with the title, followed by a row whose `.subtext` holds
    /// everything else.
    private static func parse(listingItem element: Element, url: URL?, type: API.ListingType?) -> Post {
        let id = element.id()
        let titleLink = element.first(".titleline")?.first("a")
        let title = try? titleLink?.text()
        var link = (try? titleLink?.attr("href")).flatMap { URL(string: $0, relativeTo: url) }
        var kind: Kind = type == .jobs ? .job : .normal

        guard let footer = (try? element.nextElementSibling())?.first(".subtext") else {
            l.warning("could not find sibling '.subtext' for post \(id) - most fields will be nil")
            return Post(id: id, title: title, link: link, kind: kind)
        }

        let commentLink = try? footer.select("a[href^=item]").last()

        // If the comment URL and link URL go to the same URL, it's a text post!
        if let href = try? commentLink?.attr("href"), URL(string: href, relativeTo: url) == link {
            link = nil
        }

        // Job posts have a "hide" link and nothing after it.
        if let hide = footer.first("a[href^=hide]"), (try? hide.nextElementSibling()) == nil {
            kind = .job
        }

        return Post(
            id: id,
            title: title,
            link: link,
            score: footer.text(of: ".score").flatMap(Parse.int),
            authorId: footer.text(of: ".hnuser"),
            postedDate: footer.attr("title", of: ".age").flatMap(Parse.date(fromSubline:)),
            commentCount: (try? commentLink?.text()).flatMap(commentCount(from:)),
            kind: kind
        )
    }

    /// "discuss", "1 comment" or "12 comments".
    private static func commentCount(from text: String) -> Int? {
        if text.hasSuffix("discuss") {
            return 0
        }

        if text.hasSuffix("comment") || text.hasSuffix("comments") {
            return Parse.int(text)
        }

        return nil
    }
}

struct FetchBrowseListing: InfiniteQuery {
    typealias Page = [Post]
    typealias PageParam = Int

    let type: API.ListingType

    var initialPageParam: Int { 0 }

    func fetch(page param: Int) async throws -> [Post] {
        let url = type.url(page: param)
        return try await Post.parse(fromListingPage: API.fetchHTML(url), url: url, listingType: type)
    }

    // Forward-only: as long as the last page returned posts, assume there's another. A page that
    // comes back empty (HN throws `noMoreResults` first, surfaced as the footer error) ends it.
    func nextPageParam(after last: [Post], pages _: [[Post]], params: [Int]) -> Int? {
        last.isEmpty ? nil : (params.last ?? 0) + 1
    }

    // HN paginates by position in a feed that keeps moving, so a post can slide off page N onto
    // page N+1 between two requests and arrive on both. `ForEach(posts, id: \.id)` renders that as
    // two rows with one identity, which SwiftUI resolves by jumping the scroll position around.
    // Keep the first occurrence of each post and drop the rest.
    func reconcile(_ value: PagedValue<[Post], Int>) -> PagedValue<[Post], Int> {
        var seen = Set<Post.ID>()
        return PagedValue(
            pages: value.pages.map { page in page.filter { seen.insert($0.id).inserted } },
            params: value.params
        )
    }
}

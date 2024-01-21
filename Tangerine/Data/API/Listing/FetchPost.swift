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

extension API {
    static func urlFor(postId: String, page _: Int? = nil) -> URL? {
        var url = URL(string: "https://news.ycombinator.com/item")

        url?.append(queryItems: [
            .init(name: "id", value: postId),
        ])

        return url
    }
}

private func parseText(element: Element) throws -> String {
    return element.getChildNodes().flatMap { node in
        if let node = node as? TextNode {
            return [node.text()]
        } else if let element = node as? Element {
            switch element.tagName() {
            case "a":
                if let href = try? element.attr("href"), let text = try? element.text() {
                    return ["[\(text)](\(href))"]
                }
            default:
                if let text = try? parseText(element: element) {
                    return [text]
                }
            }
        }
        return []
    }.joined(separator: "")
}

private func parseText(paragraph: Element) throws -> String {
    return paragraph.getChildNodes().flatMap { node in
        if let node = node as? TextNode {
            return [node.text()]
        } else if let element = node as? Element {
            if let text = try? parseText(element: element) {
                return [text]
            }
        }
        return []
    }.joined(separator: "\n\n")
}

extension Post {
    static func parse(fromPostPage document: Document, postId: String, url _: URL? = nil) throws -> Post {
        try? API.shared.parse(document)

        let post = Post(id: postId)

        guard let main = try? document.select("#hnmain").first() else {
            throw TangerineError.generic(.cannotParseHtml, context: "#hnmain")
        }

        guard let postContainer = try? main.select("> tbody table.fatitem").first() else {
            throw TangerineError.generic(.cannotParseHtml, context: ".fatitem")
        }

        if let textContainer = try? postContainer.select("div.toptext").first() {
            post.text = try? parseText(paragraph: textContainer)
        }

        return post
    }
}

struct FetchPost: InfiniteFetchable {
    typealias T = Post
    typealias P = Int

    static var placeholder: Post? = Post.placeholder

    var postId: String

    init(postId: String) {
        self.postId = postId
    }

    func fetch(page: Int?) async throws -> (Post, Int) {
        guard let url = API.urlFor(postId: postId, page: page) else {
            throw TangerineError.generic(.cannotCreateUrl)
        }

        let request = URLRequest(url: url)

        return try (
            Post.parse(fromPostPage: await API.shared.fetchHTML(for: request), postId: postId, url: url),
            (page ?? 0) + 1
        )
    }
}

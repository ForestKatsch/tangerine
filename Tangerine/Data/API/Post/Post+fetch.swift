//
//  FetchBrowseListing.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import OSLog
import SwiftSoup

extension API {
    static func urlFor(postId: String, page _: Int? = nil) -> URL? {
        var url = URL(string: "https://news.ycombinator.com/item")

        url?.append(queryItems: [
            .init(name: "id", value: postId),
        ])

        return url
    }
}

struct FetchPost: InfiniteFetchable {
    typealias T = Post
    typealias P = Int

    static var placeholder: Post? = Post.placeholder

    var postId: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(postId)
    }

    init(postId: String) {
        self.postId = postId
    }

    func fetch(page: Int?) async throws -> (Post, Int) {
        guard let url = API.urlFor(postId: postId, page: page) else {
            throw TangerineError.generic(.cannotCreateUrl)
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringCacheData

        return try (
            Post.parse(fromPostPage: await API.shared.fetchHTML(for: request), postId: postId, url: url),
            (page ?? 0) + 1
        )
    }
}

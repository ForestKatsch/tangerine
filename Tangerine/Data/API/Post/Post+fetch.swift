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

extension API {
    static func urlFor(postId: String, page _: Int? = nil) -> URL? {
        var url = URL(string: "https://news.ycombinator.com/item")

        url?.append(queryItems: [
            .init(name: "id", value: postId),
        ])

        return url
    }
}

struct FetchPost: Query {
    let postId: String

    func fetch() async throws -> Post {
        guard let url = API.urlFor(postId: postId) else {
            throw TangerineError.generic(.cannotCreateUrl)
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringCacheData

        return try Post.parse(fromPostPage: await API.shared.fetchHTML(for: request), postId: postId, url: url)
    }
}

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
    static func urlFor(page _: String, page _: Int? = nil) -> URL? {
        /*
         var url = type.url

         if let page {
             url?.append(queryItems: [
                 .init(name: "p", value: String(page + 1)),
             ])
         }
         return url
          */

        return nil
    }
}

extension Post {
    static func parse(fromPostPage document: Document, url _: URL? = nil) throws -> Post {
        try? API.shared.parse(document)
    }
}

struct FetchPage: InfiniteFetchable {
    typealias T = Post
    typealias P = Int

    static var placeholder: Post? = Post.placeholder

    var postId: String

    init(postId: String) {
        self.postId = postId
    }

    func fetch(page _: Int?) async throws -> (Post, Int) {
        throw TangerineError.generic(.cannotCreateUrl)

        /*
         let request = URLRequest(url: url)

         return try (
             Item.parse(fromListingPage: await API.shared.fetchHTML(for: request), url: url, listingType: type),
             (page ?? 0) + 1
         )
          */
    }
}

//
//  Post+fetch.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Aquifer
import Foundation

struct FetchPost: Query {
    let postId: String

    func fetch() async throws -> Post {
        try await Post.parse(fromPostPage: API.fetchHTML(API.itemURL(id: postId)), postId: postId)
    }
}

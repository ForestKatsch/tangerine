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
            post.text = try? Parse.parseHNText(text: textContainer).joined(separator: "\n\n")
        }

        // Ugh, comment parsing lol.
        guard let commentContainer = try? main.select("table.comment-tree > tbody").first() else {
            return post
        }

        guard let commentElements = try? commentContainer.select("> tr.athing") else {
            return post
        }

        var commentBranch: [Comment] = []

        for element in commentElements {
            guard let indentString = try? element.select("td.ind[indent]").first()?.attr("indent") else {
                print("oh no - expected indent!")
                continue
            }

            guard let indent = Int(indentString, radix: 10) else {
                print("oh no - expected indent!")
                continue
            }

            let id = element.id()
            let comment = Comment(id: id)

            if indent == commentBranch.count {
                // One deeper!
                // A <-- branch.count == 1
                //   B <-- comment: indent = 1
            } else if indent == commentBranch.count - 1 {
                // Sibling of current
                // A
                //   B <-- branch.count == 2
                //   C <-- comment: indent = 1
                _ = commentBranch.popLast()
            } else if indent < commentBranch.count {
                // Back to a previous parent!
                // A
                //   B <-- branch.count == 2
                // C <-- comment: indent = 0
                commentBranch.removeLast(commentBranch.count - indent)
            } else {
                print("oh shiiiiiit we lost our spot")
            }

            let parent = commentBranch.last

            parent?.children.append(comment)
            comment.parent = parent

            // Nothing on the branch - therefore we are a parent.
            if commentBranch.count == 0 {
                post.comments.append(comment)
            }

            commentBranch.append(comment)

            // OK, let's fill out the comment.
            if let header = try? element.select("span.comhead").first() {
                if let authorText = try? header.select(".hnuser").text() {
                    comment.authorId = authorText
                } else {
                    l.warning("could not find header '.hnuser' for comment \(comment.id)")
                }

                if let age = try? header.select(".age").first() {
                    if let postedDate = try? age.attr("title") {
                        comment.postedDate = Parse.date(fromSubline: postedDate)
                    }
                } else {
                    l.warning("could not find header '.age' for comment \(comment.id)")
                }
            }

            if let textElement = try? element.select("div.comment > .commtext").first() {
                comment.text = try? Parse.parseHNText(text: textElement).joined(separator: "\n\n")
            }
        }

        return post
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

        let request = URLRequest(url: url)

        return try (
            Post.parse(fromPostPage: await API.shared.fetchHTML(for: request), postId: postId, url: url),
            (page ?? 0) + 1
        )
    }
}

//
//  TangerineTests.swift
//  TangerineTests
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftSoup
import XCTest
@testable import Tangerine

/// Fixtures mirroring the shape of a Hacker News item page, trimmed to the parts the parser
/// actually reads. Captured from live HN markup — notably, HN omits `<tbody>` entirely and leaves
/// the HTML parser to imply it, which is load-bearing for how the comment tree is matched.
private enum HN {
    /// One comment row. `indent` is what HN uses instead of nesting the markup.
    static func comment(id: String, indent: Int, author: String, text: String) -> String {
        """
        <tr class="athing comtr" id="\(id)"><td><table border="0"><tr>
        <td class="ind" indent="\(indent)"><img src="s.gif" height="1" width="0"></td>
        <td valign="top" class="votelinks"><center></center></td>
        <td class="default">
        <div><span class="comhead">
        <a href="user?id=\(author)" class="hnuser">\(author)</a>
        <span class="age" title="2026-09-19T18:44:12"><a href="item?id=\(id)">1 hour ago</a></span>
        </span></div><br>
        <div class="comment"><div class="commtext c00">\(text)</div></div>
        </td></tr></table></td></tr>
        """
    }

    /// A whole item page. `commentTree` is dropped in verbatim so a test can supply a populated
    /// tree, an empty one, or nothing at all.
    static func itemPage(commentTree: String) -> String {
        """
        <html><body><center><table id="hnmain"><tr><td>
        <table class="fatitem"><tr class="athing" id="1"><td>
        <span class="titleline"><a href="https://example.com/">Example post</a></span>
        </td></tr></table>
        \(commentTree)
        </td></tr></table></center></body></html>
        """
    }
}

final class PostParsingTests: XCTestCase {
    private func parsePost(_ html: String) throws -> Post {
        try Post.parse(fromPostPage: SwiftSoup.parse(html), postId: "1")
    }

    func testParsesFlatCommentsIntoATree() throws {
        let tree = """
        <table border="0" class="comment-tree">
        \(HN.comment(id: "10", indent: 0, author: "alice", text: "Top level"))
        \(HN.comment(id: "11", indent: 1, author: "bob", text: "A reply"))
        \(HN.comment(id: "12", indent: 0, author: "carol", text: "Another top level"))
        </table>
        """

        let post = try parsePost(HN.itemPage(commentTree: tree))

        XCTAssertEqual(post.comments.count, 2, "two top-level comments, the reply nested under the first")
        XCTAssertEqual(post.comments.first?.authorId, "alice")
        XCTAssertEqual(post.comments.first?.text, "Top level")
        XCTAssertEqual(post.comments.first?.children.count, 1)
        XCTAssertEqual(post.comments.first?.children.first?.authorId, "bob")
        XCTAssertEqual(post.comments.last?.authorId, "carol")
        XCTAssertTrue(post.comments.last?.children.isEmpty ?? false)
    }

    /// HN sends a bare `<table class="comment-tree"></table>` for a post nobody has replied to —
    /// every job posting, for one. With no rows the HTML parser never implies a `<tbody>`, so
    /// matching the tree by its `tbody` would mistake this for a broken page.
    func testEmptyCommentTreeParsesAsZeroComments() throws {
        let post = try parsePost(HN.itemPage(commentTree: #"<table border="0" class="comment-tree"></table>"#))

        XCTAssertTrue(post.comments.isEmpty)
    }

    /// The counterpart: no tree at all means the page wasn't what we expected. Returning an empty
    /// post here would be indistinguishable from the case above, which is how a failed load used
    /// to surface in the UI as "No comments".
    func testMissingCommentTreeThrows() {
        XCTAssertThrowsError(try parsePost(HN.itemPage(commentTree: "")))
    }

    func testDeeplyNestedRepliesUnwindToTheRightParent() throws {
        let tree = """
        <table border="0" class="comment-tree">
        \(HN.comment(id: "20", indent: 0, author: "a", text: "root"))
        \(HN.comment(id: "21", indent: 1, author: "b", text: "child"))
        \(HN.comment(id: "22", indent: 2, author: "c", text: "grandchild"))
        \(HN.comment(id: "23", indent: 1, author: "d", text: "back up one"))
        </table>
        """

        let post = try parsePost(HN.itemPage(commentTree: tree))

        XCTAssertEqual(post.comments.count, 1)
        let root = try XCTUnwrap(post.comments.first)
        XCTAssertEqual(root.children.count, 2, "'child' and 'back up one' are both replies to the root")
        XCTAssertEqual(root.children.first?.children.first?.authorId, "c")
        XCTAssertEqual(root.children.last?.authorId, "d")
    }
}

final class PostMergeTests: XCTestCase {
    private let listing = Post(
        id: "1", title: "From the listing", link: URL(string: "https://example.com/"),
        score: 100, authorId: "alice", commentCount: 2, kind: .normal
    )

    func testMergeKeepsListingMetadataAndTakesFetchedBody() {
        let fetched = Post(
            id: "1", title: nil, text: "Body text",
            comments: [Comment(id: "10", text: "Hi", authorId: "bob", indent: 0)]
        )

        let merged = listing.merge(from: fetched)

        XCTAssertEqual(merged.title, "From the listing", "the item page doesn't re-parse the title")
        XCTAssertEqual(merged.score, 100)
        XCTAssertEqual(merged.commentCount, 2)
        XCTAssertEqual(merged.text, "Body text")
        XCTAssertEqual(merged.comments.count, 1)
    }

    func testMergeIgnoresADifferentPost() {
        let other = Post(id: "999", text: "Wrong post", comments: [])

        XCTAssertEqual(listing.merge(from: other).text, nil)
    }
}

final class ReadManagerTests: XCTestCase {
    func testMarksAndReadsByPostIdentity() {
        let manager = ReadManager()
        let post = Post(id: "1", title: "A post")
        // Equal by id, so a post rebuilt by `merge` still counts as the same one.
        let sameIdDifferentFields = Post(id: "1", title: "A post", score: 50)

        XCTAssertFalse(manager.hasVisited(post))

        manager.markVisited(post)

        XCTAssertTrue(manager.hasVisited(post))
        XCTAssertTrue(manager.hasVisited(sameIdDifferentFields))
        XCTAssertFalse(manager.hasVisited(Post(id: "2", title: "Another")))
    }
}

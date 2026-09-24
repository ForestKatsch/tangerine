//
//  API.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import os
import SwiftSoup

private let l = Logger(category: "API")

/// Hacker News, scraped from its HTML pages.
enum API {
    /// `String`-backed so a selected listing can round-trip through `@SceneStorage`.
    enum ListingType: String, Hashable, Identifiable, CaseIterable {
        case news
        case new
        case ask
        case show
        case jobs

        var id: Self { self }
    }

    static func itemURL(id: String) -> URL {
        URL(string: "https://news.ycombinator.com/item?id=\(id)")!
    }

    private static let userAgent =
        "Tangerine / \(Bundle.main.appVersionLong ?? "?") (build #\(Bundle.main.appBuild ?? "?"))"

    /// Fetches and parses the HTML page at `url`.
    static func fetchHTML(_ url: URL, cachePolicy: URLRequest.CachePolicy = .reloadIgnoringCacheData) async throws -> Document {
        let html = try await String(decoding: fetch(URLRequest(url: url, cachePolicy: cachePolicy)), as: UTF8.self)

        if html.isEmpty {
            throw TangerineError.generic(.cannotConvertToUtf8)
        }

        guard let document = try? SwiftSoup.parse(html) else {
            throw TangerineError.generic(.cannotParseHtml)
        }

        return document
    }

    /// Fetches `request`, turning any failure — including a non-2xx status — into a `TangerineError`.
    private static func fetch(_ request: URLRequest) async throws -> Data {
        var request = request
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let description = "\(request.httpMethod ?? "??") \(request.url?.absoluteString ?? "??")"
        l.trace("\(description)")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw TangerineError.generic(.notHttpResponse)
            }

            guard (200 ... 299).contains(response.statusCode) else {
                l.trace("request unsuccessful: \(response.statusCode) \(description)")
                throw TangerineError.network(response.statusCode)
            }

            return data
        } catch {
            throw TangerineError.from(error)
        }
    }
}

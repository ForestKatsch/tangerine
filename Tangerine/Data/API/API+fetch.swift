//
//  API+fetch.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import os
import SwiftSoup

private let l = Logger(category: "API")

extension API {
    static var userAgent: String {
        let appVersion = "\(Bundle.main.appVersionLong ?? "?") (build #\(Bundle.main.appBuild ?? "?"))"
        return "Tangerine / \(appVersion)"
    }

    // Fetches and parses the given HTML file.
    func fetchHTML(for request: URLRequest) async throws -> Document {
        let (data, _) = try await fetchHTTP(for: request)

        let str = String(decoding: data, as: UTF8.self)

        if str.count == 0 {
            throw TangerineError.generic(.cannotConvertToUtf8)
        }

        guard let doc: Document = try? SwiftSoup.parse(str) else {
            throw TangerineError.generic(.cannotParseHtml)
        }

        return doc
    }

    // Fetches HTTP pages and handles errors.
    func fetchHTTP(for inRequest: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var request = inRequest

        request.setValue(API.userAgent, forHTTPHeaderField: "User-Agent")

        l.trace("\(request.httpMethod ?? "??") \(request.url?.absoluteString ?? "??")")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // try await Task.sleep(nanoseconds: 1_000_000_000)

            guard let httpResponse = response.http else {
                throw TangerineError.generic(.notHttpResponse)
            }

            if httpResponse.isSuccessful {
                return (data, httpResponse)
            }

            l.trace("request unsuccessful: \(request.httpMethod ?? "??") \(httpResponse.statusCode) \(request.url?.absoluteString ?? "??")")
            throw TangerineError.network(httpResponse.statusCode)
        } catch {
            throw TangerineError.from(error)
            // print(error)
            // throw TangerineError.network(0)
        }
    }
}

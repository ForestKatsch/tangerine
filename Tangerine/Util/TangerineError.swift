//
//  TangerineError.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation

enum ErrorCode: Int {
    case unspecified = 1000
    case notImplemented
    case otherError
    case methodWithoutOverride

    case notHttpResponse = 2000
    case cannotCreateUrl
    case cannotConvertToUtf8
    case cannotParseHtml
    case queryTypeMismatch
}

enum TangerineError: Error {
    case generic(_ reason: ErrorCode = .unspecified, context: String? = nil)
    case network(_ statusCode: Int? = nil, context: String? = nil)
    case noMoreResults

    static func from(_ error: Error) -> TangerineError {
        if let error = error as? TangerineError {
            return error
        }

        return .generic(.otherError)
    }
}

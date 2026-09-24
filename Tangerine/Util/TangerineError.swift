//
//  TangerineError.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

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
        error as? TangerineError ?? .generic(.otherError)
    }

    var name: LocalizedStringKey {
        switch self {
        case .generic: "error.generic"
        case .network: "error.network"
        case .noMoreResults: "error.noMoreResults"
        }
    }

    var systemImage: String {
        switch self {
        case .noMoreResults: "slash.circle"
        default: "exclamationmark.triangle"
        }
    }

    var detail: LocalizedStringKey? {
        switch self {
        case let .generic(code, context):
            let codeName = String(describing: code)

            if let context {
                return "E\(String(code.rawValue)) .\(codeName)\n\(context)"
            }

            return "E\(String(code.rawValue)) .\(codeName)"
        case let .network(statusCode, context):
            guard let statusCode else {
                return "error.network.\(context ?? "")"
            }

            let contextString = context.map { " (\($0))" } ?? ""
            return "error.network.\(statusCode).\(contextString)"
        case .noMoreResults:
            return nil
        }
    }
}

//
//  TangerineError.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
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

    static func from(_ error: Error) -> TangerineError {
        if let error = error as? TangerineError {
            return error
        }

        return .generic(.otherError)
    }

    var name: LocalizedStringKey {
        switch self {
        case .generic:
            return "Unexpected Error"
        case .network:
            return "Network Error"
        }
    }

    var detail: LocalizedStringKey? {
        switch self {
        case let .generic(code, context):
            // TODO: switch based on prod/dev
            let codeName = String(describing: code)

            if let context {
                return "E\(String(code.rawValue)) .\(codeName)\n\(context)"
            }

            return "E\(String(code.rawValue)) .\(codeName)"
        case let .network(statusCode, context):
            guard let statusCode else {
                return "Network Error\(context ?? "")"
            }

            let contextString = context == nil ? "" : " (\(context!))"
            return "Network Error \(statusCode)\(contextString)"
        }
    }
}

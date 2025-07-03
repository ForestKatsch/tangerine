//
//  TangerineError+view.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import Foundation
import SwiftUI

extension TangerineError {
    var name: LocalizedStringKey {
        switch self {
        case .generic:
            "error.generic"
        case .network:
            "error.network"
        case .noMoreResults:
            "error.noMoreResults"
        }
    }

    var systemImage: String {
        switch self {
        case .noMoreResults:
            "slash.circle"
        default:
            "exclamationmark.triangle"
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
                return "error.network.\(context ?? "")"
            }

            let contextString = context == nil ? "" : " (\(context!))"
            return "error.network.\(statusCode).\(contextString)"
        default:
            return nil
        }
    }
}

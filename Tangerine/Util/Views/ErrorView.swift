//
//  ErrorView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import SwiftUI

struct ErrorView: View {
    var error: Error?

    init(_ error: Error? = nil) {
        self.error = error
    }

    var body: some View {
        guard let error = error as? TangerineError else {
            return AnyView(ContentUnavailableView("Unexpected Error", systemImage: "exclamationmark.triangle"))
        }

        if let detail = error.detail {
            return AnyView(ContentUnavailableView(error.name, systemImage: error.systemImage, description: Text(detail)))
        } else {
            return AnyView(ContentUnavailableView(error.name, systemImage: error.systemImage))
        }
    }
}

#Preview {
    ErrorView()
}

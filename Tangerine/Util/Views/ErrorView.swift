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
        if let error = error as? TangerineError {
            ContentUnavailableView(error.name, systemImage: error.systemImage, description: error.detail.map { Text($0) })
        } else {
            ContentUnavailableView("error.generic", systemImage: "exclamationmark.triangle")
        }
    }
}

#Preview {
    ErrorView()
}

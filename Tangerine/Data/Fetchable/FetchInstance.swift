//
//  FetchInstance.swift
//  Pensieve
//
//  Created by Forest Katsch on 8/23/23.
//

import Foundation
import SwiftUI

enum FetchState {
    case fetching
    case idle
}

actor Background {}

@Observable
class FetchInstance<F: Fetchable> {
    let fetchable: F

    var data: F.T?
    var error: Error?

    var fetchState: FetchState = .idle

    init(_ fetchable: F) {
        self.fetchable = fetchable
    }

    func fetchImmediate() async throws {
        if fetchState != .idle {
            return
        }

        fetchState = .fetching

        do {
            data = try await fetchable.fetch()
            fetchState = .idle
        } catch {
            fetchState = .idle
            self.error = error
        }
    }
}

extension FetchInstance {
    func onAppear() {
        if data != nil {
            return
        }

        Task {
            try? await fetchImmediate()
        }
    }

    func onDisappear() {}
}

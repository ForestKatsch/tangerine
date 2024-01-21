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

    var isLoading: Bool { data == nil && fetchState == .fetching }

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

@Observable
class InfiniteFetchInstance<F: InfiniteFetchable> {
    let fetchable: F

    var data: [F.T] = []
    var error: Error?

    var page: F.P?

    var fetchState: FetchState = .idle

    var isLoading: Bool { data.count == 0 && fetchState == .fetching }

    init(_ fetchable: F) {
        self.fetchable = fetchable
    }

    // Performs _only_ a first fetch.
    func fetchImmediate() async throws {
        if fetchState != .idle {
            return
        }

        if let (data, page) = try await fetchPage(after: nil) {
            self.data = [data]
            self.page = page
        }
    }

    // Performs _only_ a first fetch.
    func fetchNext() async throws {
        if fetchState != .idle {
            return
        }

        if data.count == 0 {
            return
        }

        if let (data, page) = try await fetchPage(after: page) {
            self.data.append(data)
            self.page = page
        }
    }

    private func fetchPage(after: F.P?) async throws -> (F.T, F.P)? {
        fetchState = .fetching

        do {
            let (data, page) = try await fetchable.fetch(page: after)
            fetchState = .idle
            return (data, page)
        } catch {
            fetchState = .idle
            self.error = error

            return nil
        }
    }
}

extension InfiniteFetchInstance {
    func onAppear() {
        // Only fetch if we have no data yet.
        if data.count != 0 {
            return
        }

        Task {
            try? await fetchImmediate()
        }
    }

    func onDisappear() {}

    func onEnd() {
        Task {
            try? await fetchNext()
        }
    }
}

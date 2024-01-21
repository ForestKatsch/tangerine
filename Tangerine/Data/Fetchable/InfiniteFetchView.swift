//
//  FetchView.swift
//  Pensieve
//
//  Created by Forest Katsch on 8/22/23.
//

import Foundation
import SwiftUI

struct FetchStatus {
    var fetchState: FetchState
    var isFetching: Bool
    var isLoading: Bool
    var error: Error?
}

struct InfiniteFetchView<Request: InfiniteFetchable, Content: View>: View {
    @ViewBuilder
    var content: ([Request.T], @escaping () -> Void, FetchStatus) -> Content

    var request: Request
    var instance: InfiniteFetchInstance<Request>
    var fetchState: FetchState { instance.fetchState }

    var data: [Request.T] { instance.data }
    var error: Error? { instance.error }

    var status: FetchStatus {
        .init(
            fetchState: fetchState,
            isFetching: fetchState == .fetching,
            isLoading: data.isEmpty && fetchState == .fetching,
            error: error
        )
    }

    init(_ request: Request, @ViewBuilder content: @escaping ([Request.T], @escaping () -> Void, FetchStatus) -> Content) {
        self.request = request
        self.instance = FetchInstanceCache.shared.get(infinite: request)
        self.content = content
    }

    func errorView(_ error: Error) -> some View {
        guard let error = error as? TangerineError else {
            return AnyView(ContentUnavailableView("Unexpected Error", systemImage: "exclamationmark.triangle", description: Text(error.localizedDescription)))
        }

        if let detail = error.detail {
            return AnyView(ContentUnavailableView(error.name, systemImage: "exclamationmark.triangle", description: Text(detail)))
        } else {
            return AnyView(ContentUnavailableView(error.name, systemImage: "exclamationmark.triangle"))
        }
    }

    func loadNext() {
        instance.onEnd()
    }

    @ViewBuilder
    var fetchStateView: some View {
        // Data!
        if data.count > 0 {
            content(data, loadNext, status)
            // Error?
        } else if let error {
            CenteredScrollView {
                errorView(error)
            }
            // Loading...
        } else if let placeholder = Request.placeholder {
            content([placeholder], {}, status)
                .redacted(reason: .placeholder)
        } else {
            CenteredScrollView {
                ZStack {
                    ProgressView()
                }
            }
        }
    }

    var body: some View {
        fetchStateView
            .onChange(of: request, initial: true) {
                instance.onAppear()
            }
            .onDisappear {
                instance.onDisappear()
            }
            .refreshable {
                try? await instance.fetchImmediate()
            }
    }
}

struct InfiniteEnd: View {
    var next: () -> Void
    var error: Error?

    var body: some View {
        ZStack(alignment: .center) {
            if error != nil {
                ErrorView(error)
                // TODO: "try again" button
            } else {
                Text("Loading...")
                    .textCase(.uppercase)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .listRowSeparator(.hidden)
        .frame(maxWidth: .infinity)
        .onAppear {
            next()
        }
    }
}

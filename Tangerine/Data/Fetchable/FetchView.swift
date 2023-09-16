//
//  FetchView.swift
//  Pensieve
//
//  Created by Forest Katsch on 8/22/23.
//

import Foundation
import SwiftUI

struct CenteredScrollView<Content: View>: View {
    @ViewBuilder
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geom in
            ScrollView {
                content()
                    .frame(maxWidth: .infinity, minHeight: geom.size.height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FetchView<Request: Fetchable, Content: View>: View {
    @ViewBuilder
    var content: (Request.T) -> Content

    var request: Request
    var instance: FetchInstance<Request>
    var fetchState: FetchState { instance.fetchState }

    var data: Request.T? { instance.data }
    var error: Error? { instance.error }

    init(_ request: Request, @ViewBuilder content: @escaping (Request.T) -> Content) {
        self.request = request
        self.instance = FetchInstanceCache.shared.get(request)
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

    @ViewBuilder
    var thingy: some View {
        // Data!
        if let data {
            content(data)
            // Error?
        } else if let error {
            CenteredScrollView {
                errorView(error)
            }
            // Loading...
        } else if let placeholder = Request.placeholder {
            CenteredScrollView {
                content(placeholder)
                    .redacted(reason: .placeholder)
            }
        } else {
            CenteredScrollView {
                ZStack {
                    ProgressView()
                }
            }
        }
    }

    var body: some View {
        thingy
            .onChange(of: request, initial: true) {
                instance.onAppear()
            }
            .onDisappear {
                instance.onDisappear()
            }
            .refreshable {
                print("fetchstart")
                try? await instance.fetchImmediate()
                print("fetchdone")
            }
    }
}

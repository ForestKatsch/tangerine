//
//  ProminentExternalLink.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import Defaults
import SwiftSoup
import SwiftUI

/// A link shown as a card with the page's title, description and image, read from its Open
/// Graph tags.
struct ProminentExternalLink: View {
    struct Metadata {
        var title: String
        var description: String?
        var imageUrl: URL?
    }

    enum FetchState {
        case idle
        case fetching
        case done
    }

    /// Fetched metadata by URL, so a card that scrolls away and back doesn't fetch again.
    private static var cache: [URL: Metadata?] = [:]

    @Default(.linkPreviewMode)
    var linkPreviewMode

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var url: URL

    @State
    var metadata: Metadata?

    @State
    var imageLoaded = false

    @State
    var state = FetchState.idle

    init(_ url: URL) {
        self.url = url
    }

    var showAsLandscape: Bool {
        #if os(macOS)
            true
        #else
            horizontalSizeClass == .regular
        #endif
    }

    func fetch() async {
        guard state == .idle, metadata == nil else {
            return
        }

        state = .fetching

        let document = try? await API.fetchHTML(url, cachePolicy: .returnCacheDataElseLoad)
        let metadata = document.flatMap(Self.metadata(from:))

        withAnimation {
            state = .done
            self.metadata = metadata
        }

        Self.cache[url] = .some(metadata)
    }

    static func metadata(from document: Document) -> Metadata? {
        guard let title = document.attr("content", of: "meta[property=og:title]") else {
            return (try? document.first("title")?.text()).map { Metadata(title: $0) }
        }

        let description = document.attr("content", of: "meta[property=og:description]")?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Metadata(
            title: title,
            description: description?.isEmpty == false ? description : nil,
            imageUrl: document.attr("content", of: "meta[property=og:image]").flatMap { URL(string: $0) }
        )
    }

    @ViewBuilder
    var image: some View {
        if linkPreviewMode == .titleAndImage {
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(.clear)
                    .aspectRatio(1.91 / 1, contentMode: .fit)

                if let imageUrl = metadata?.imageUrl {
                    Rectangle()
                        .fill(.clear)
                        .background {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .blur(radius: imageLoaded ? 0 : 20)
                                    .opacity(imageLoaded ? 1 : 0)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            imageLoaded = true
                                        }
                                    }
                            } placeholder: {
                                EmptyView()
                            }
                        }
                } else if state == .done {
                    Image(systemName: "text.page.fill")
                        .font(.largeTitle)
                        .imageScale(.large)
                        .foregroundStyle(.tertiary)
                }
            }
            .clipped()
        }
    }

    var text: some View {
        VStack(alignment: .leading, spacing: .spacingSmall) {
            Text(url.host() ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text(metadata?.title.trimmingCharacters(in: .whitespaces) ?? url.host() ?? "")
                .font(.headline)
                .lineLimit(2)
            if let description = metadata?.description {
                Text(description.trimmingCharacters(in: .whitespaces))
                    .font(.subheadline)
                    .lineLimit(showAsLandscape ? 8 : 3)
            }
        }
        .multilineTextAlignment(.leading)
        .padding()
    }

    @ViewBuilder
    var preview: some View {
        if showAsLandscape {
            HStack(alignment: .center, spacing: 0) {
                image
                    .frame(maxWidth: 320)
                text
                    .frame(maxWidth: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                image
                text
            }
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    var linkOnly: some View {
        HStack {
            Text(url.absoluteString)
                .font(.subheadline)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.accent)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    @ViewBuilder
    var contents: some View {
        if linkPreviewMode == .linkOnly {
            linkOnly
        } else {
            preview
                .if(state != .done) { $0.redacted(reason: .placeholder) }
        }
    }

    var body: some View {
        PlainExternalLink(url) {
            contents
                .clipShape(RoundedRectangle(cornerRadius: .radius))
                .background {
                    RoundedRectangle(cornerRadius: .radius)
                        .fill(.background)
                }
            #if os(iOS) || os(macOS)
                .overlay {
                    RoundedRectangle(cornerRadius: .radius)
                        .stroke(.fill)
                }
            #endif
        }
        .buttonStyle(.plain)
        .buttonBorderShape(.roundedRectangle(radius: .radius))
        .onAppear {
            if let cached = Self.cache[url] {
                state = .done
                metadata = cached
            } else {
                Task { await fetch() }
            }
        }
        .id(url)
    }
}

#Preview {
    ProminentExternalLink(URL(string: "https://arstechnica.com/gadgets/2024/01/alexa-is-in-trouble-paid-for-alexa-gives-inaccurate-answers-in-early-demos/")!)
        .padding()
}

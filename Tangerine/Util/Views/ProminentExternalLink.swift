//
//  OpenGraphLink.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/20/24.
//

import Defaults
import SwiftUI

extension LinkPreviewMode {
    var showImage: Bool {
        switch self {
        case .textAndImage:
            return true
        default:
            return false
        }
    }
}

struct ProminentExternalLink: View {
    @Default(.linkPreviewMode)
    var linkPreviewMode

    struct Metadata {
        var title: String
        var description: String?
        var imageUrl: URL?
    }

    var url: URL

    init(_ url: URL) {
        self.url = url
    }

    @State
    var metadata: Metadata?

    enum FetchState {
        case idle
        case fetching
        case done
    }

    @State
    var imageLoaded = false

    @State
    var state = FetchState.idle

    func fetch() async {
        if state != .idle {
            return
        }

        state = .fetching

        var metadata: Metadata?

        defer {
            state = .done
            self.metadata = metadata
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        guard let document = try? await API.shared.fetchHTML(for: request) else {
            return
        }

        guard let titleText = try? document.select("meta[property=og:title]").first()?.attr("content") else {
            if let titleText = try? document.select("title").first()?.text() {
                metadata = Metadata(title: titleText)
            }
            return
        }

        metadata = Metadata(title: titleText)

        if let descriptionText = try? document.select("meta[property=og:description]").first()?.attr("content") {
            let description = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)

            if !description.isEmpty {
                metadata?.description = description
            }
        }

        if let imageUrl = try? document.select("meta[property=og:image]").first()?.attr("content") {
            metadata?.imageUrl = URL(string: imageUrl)
        }
    }

    @ViewBuilder
    var image: some View {
        if !linkPreviewMode.showImage {
            EmptyView()
        } else if let imageUrl = metadata?.imageUrl {
            ZStack(alignment: .center) {
                Spacer()
                    .aspectRatio(1.91 / 1, contentMode: .fit)

                Rectangle()
                    .fill(.clear)
                    .background {
                        AsyncImage(url: imageUrl, content: { image in
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
                        }, placeholder: {
                            ProgressView()
                        })
                    }
            }
            .clipped()
        } else {
            EmptyView()
        }
    }

    var chevron: some View {
        Image(systemName: "chevron.right")
            .foregroundStyle(.secondary)
    }

    @ViewBuilder
    var text: some View {
        HStack(spacing: .spacingSmall) {
            VStack(alignment: .leading, spacing: .spacingSmall) {
                Text(url.host() ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(metadata?.title.trimmingCharacters(in: .whitespaces) ?? "")
                    .font(.headline)
                if let description = metadata?.description {
                    Text(description.trimmingCharacters(in: .whitespaces))
                        .font(.subheadline)
                        .lineLimit(showAsLandscape ? 8 : 3)
                }
            }
            .multilineTextAlignment(.leading)
            Spacer()
            chevron
        }
        .padding()
    }

    @ViewBuilder
    var portrait: some View {
        VStack(alignment: .leading, spacing: 0) {
            image
            text
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    var landscape: some View {
        HStack(alignment: .center, spacing: 0) {
            image
                .frame(maxWidth: 400)
            text
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    var preview: some View {
        if showAsLandscape {
            landscape
        } else {
            portrait
        }
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var showAsLandscape: Bool {
        #if os(macOS)
            true
        #else
            horizontalSizeClass == .regular
        #endif
    }

    var previewUrl: some View {
        HStack {
            Text(url.absoluteString)
                .font(.subheadline)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.accent)
            Spacer()
            chevron
        }
        .padding()
    }

    @ViewBuilder
    var contents: some View {
        if linkPreviewMode == .linkOnly {
            previewUrl
        } else if metadata != nil {
            preview
        } else if state == .done {
            previewUrl
        } else {
            HStack {
                ProgressView()
                Spacer()
            }
            .padding()
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
            #if os(iOS)
                .overlay {
                    RoundedRectangle(cornerRadius: .radius)
                        .stroke(.fill)
                }
            #endif
        }
        .buttonStyle(.plain)
        .buttonBorderShape(.roundedRectangle(radius: .radius))
        .onAppear {
            Task {
                await fetch()
            }
        }
    }
}

#Preview {
    // ProminentExternalLink(URL(string: "https://apple.com/vision-pro")!)
    // ProminentExternalLink(URL(string: "https://nightshade.cs.uchicago.edu/whatis.html")!)
    ProminentExternalLink(URL(string: "https://arstechnica.com/gadgets/2024/01/alexa-is-in-trouble-paid-for-alexa-gives-inaccurate-answers-in-early-demos/")!)
        // ProminentExternalLink(URL(string: "https://www.machinedesign.com/3d-printing-cad/article/21263614/how-to-build-your-own-injection-molding-machine")!)
        .padding()
}

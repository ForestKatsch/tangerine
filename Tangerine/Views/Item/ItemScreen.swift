//
//  ItemScreen.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import SwiftUI

#if os(visionOS)
    private let nativeTitle = true
    private let scoreButtonHeight: CGFloat = 44
#else
    private let nativeTitle = false
    private let scoreButtonHeight: CGFloat = 20
#endif

struct ScoreButton<Content: View>: View {
    var label: () -> Content

    @Binding
    var isVoted: Bool

    init(isVoted: Binding<Bool>, @ViewBuilder label: @escaping () -> Content) {
        self._isVoted = isVoted
        self.label = label
    }

    var labelView: some View {
        Button(action: {
            withAnimation { isVoted.toggle() }

            Haptics.impact()
        }) {
            label()
                .fixedSize()
                .frame(height: scoreButtonHeight)
        }
    }

    @ViewBuilder
    var contentView: some View {
        if isVoted {
            labelView
                .buttonStyle(.borderedProminent)
                .tint(.accent)
                .foregroundStyle(.white)
        } else {
            labelView
                .foregroundStyle(.primary)
                .buttonStyle(.bordered)
        }
    }

    var body: some View {
        contentView
    }
}

struct ScoreView: View {
    var score: Int

    @State
    var votedUp: Bool = false

    @State
    var votedDown: Bool = false

    var body: some View {
        HStack(spacing: 2) {
            ScoreButton(isVoted: $votedUp) {
                Label(score.formatted(), systemImage: "arrow.up")
            }
            /*
             ScoreButton(isVoted: $votedDown) {
                 Label(score.formatted(), systemImage: "arrow.down")
                     .labelStyle(.iconOnly)
             }
              */
        }
    }
}

struct ItemScreen: View {
    var item: Item

    init(_ item: Item) {
        self.item = item
    }

    var title: LocalizedStringKey {
        if let title = item.title {
            return "\(title)"
        }

        if let commentCount = item.commentCount {
            return "\(commentCount, format: .number) comments"
        }

        return "\(item.id)"
    }

    @ViewBuilder
    var linkView: some View {
        if let url = item.link {
            ExternalLink(url) {
                HStack(alignment: .firstTextBaseline, spacing: .spacingSmall) {
                    Label(Formatter.format(urlWithoutPrefix: url), systemImage: "link")
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                }
            }
            .font(.footnote)
        }
    }

    @ViewBuilder
    var titleView: some View {
        if let title = item.title {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
        }
    }

    @ViewBuilder
    var scoreView: some View {
        if let score = item.score {
            ScoreView(score: score)
        }
    }

    @ViewBuilder
    var authorView: some View {
        if let authorId = item.authorId {
            Label(authorId, systemImage: "person.fill")
                .foregroundStyle(.secondary)
                .fixedSize()
        }
    }

    @ViewBuilder
    var postedDateView: some View {
        if let date = item.postedDate {
            Text(date.formatted(.relative(presentation: .named)))
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    var infoLeadingView: some View {
        if item.kind == .job {
            Image(systemName: Item.Kind.job.systemImage)
        } else {
            HStack(spacing: .spacingMedium) {
                scoreView
                authorView
            }
        }
    }

    @ViewBuilder
    var infoView: some View {
        HStack(spacing: .spacingMedium) {
            infoLeadingView
            Spacer()
            postedDateView
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    var headerView: some View {
        VStack(alignment: .leading, spacing: .spacingLarge) {
            if !nativeTitle {
                titleView
            }
            linkView
            infoView
            #if os(visionOS)
            .frame(minHeight: 50)
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var commentsView: some View {
        VStack {
            ContentUnavailableView("Comments not implemented yet", systemImage: "exclamationmark.bubble")
            ExternalLink(item.hnUrl) {
                Label("Open comments in Safari", systemImage: "safari")
            }
        }
    }

    var body: some View {
        CenteredScrollView {
            VStack(alignment: .leading) {
                headerView
                    .padding(.bottom)
                    .padding(.horizontal, .spacingHorizontal)
                ZStack(alignment: .center) {
                    commentsView
                        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .padding(.horizontal, .spacingHorizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toolbar {
            ToolbarItem {
                ShareLink("Share", item: item.hnUrl)
            }
        }
        .navigationTitle(nativeTitle ? title : "")
        #if !os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    ItemScreen(.placeholder)
}

//
//  ScoreView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/19/24.
//

import Foundation
import SwiftUI

struct ScoreButton<Content: View>: View {
    var action: () -> Void
    var label: () -> Content

    @Binding
    var isVoted: Bool

    init(isVoted: Binding<Bool>, action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Content) {
        self._isVoted = isVoted
        self.action = action
        self.label = label
    }

    var labelView: some View {
        Button(action: {
            action()
            Haptics.impact()
        }) {
            label()
                .fixedSize()
            #if os(iOS)
                .padding(.horizontal, .spacingSmall)
                .frame(minHeight: 32)
            #endif
        }
    }

    @ViewBuilder
    var contentView: some View {
        if isVoted {
            labelView
                .tint(.accent)
        } else {
            labelView
        }
    }

    var body: some View {
        contentView
            .buttonStyle(.glass)
    }
}

struct ScoreView: View {
    var score: Int

    @Binding
    var votedUp: Bool

    @Binding
    var votedDown: Bool

    var voteUp: () -> Void

    var voteDown: () -> Void

    var canDown: Bool = false

    @ViewBuilder
    var contents: some View {
        HStack(spacing: 10) {
            ScoreButton(isVoted: $votedUp, action: voteUp) {
                Label(score.formatted(), systemImage: "arrowtriangle.up")
            }
            if canDown {
                ScoreButton(isVoted: $votedDown, action: voteDown) {
                    Label(score.formatted(), systemImage: "arrowtriangle.down")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }

    var body: some View {
        #if os(iOS) || os(macOS)
            GlassEffectContainer {
                contents
            }
        #else
            contents
        #endif
    }
}

struct PostScoreView: View {
    var post: Post

    @State
    var votedUp: Bool = false

    @State
    var votedDown: Bool = false

    var voteDiff: Int {
        votedUp ? 1 : votedDown ? -1 : 0
    }

    var body: some View {
        ScoreView(score: (post.score ?? 0) + voteDiff, votedUp: $votedUp, votedDown: $votedDown) {} voteDown: {}
            .disabled(true)
    }
}

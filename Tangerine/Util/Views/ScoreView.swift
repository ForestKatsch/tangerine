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
                .frame(minHeight: 25)
            #endif
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

    @Binding
    var votedUp: Bool

    @Binding
    var votedDown: Bool

    var voteUp: () -> Void

    var voteDown: () -> Void

    var canDown: Bool = false

    var body: some View {
        HStack(spacing: 2) {
            ScoreButton(isVoted: $votedUp, action: voteUp) {
                Label(score.formatted(), systemImage: "arrow.up")
            }
            if canDown {
                ScoreButton(isVoted: $votedDown, action: voteDown) {
                    Label(score.formatted(), systemImage: "arrow.down")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }
}

struct PostScoreView: View {
    var post: Post

    @State
    var votedUp: Bool = false

    @State
    var votedDown: Bool = false

    var body: some View {
        ScoreView(score: post.score ?? 0, votedUp: $votedUp, votedDown: $votedDown) {
            votedUp = !votedUp
        } voteDown: {
            votedDown = !votedDown
        }
        .disabled(true)
    }
}

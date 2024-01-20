//
//  ScoreView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/19/24.
//

import Foundation
import SwiftUI

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
            withAnimation {
                isVoted.toggle()
            }

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

    var canDown: Bool = false

    var body: some View {
        HStack(spacing: 2) {
            ScoreButton(isVoted: $votedUp) {
                Label(score.formatted(), systemImage: "arrow.up")
            }
            if canDown {
                ScoreButton(isVoted: $votedDown) {
                    Label(score.formatted(), systemImage: "arrow.down")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }
}

struct PostScoreView: View {
    var post: Item

    @State
    var votedUp: Bool = false

    @State
    var votedDown: Bool = false

    var body: some View {
        ScoreView(score: post.score ?? 0, votedUp: $votedUp, votedDown: $votedDown)
            .onChange(of: votedUp, initial: true) { voted, _ in
                if voted {
                    post.vote(.up)
                }
            }
    }
}

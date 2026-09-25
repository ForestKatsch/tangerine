//
//  ScoreView.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/19/24.
//

import SwiftUI

/// A post's score, on an upvote button that stays disabled until voting is implemented.
struct PostScoreView: View {
    var post: Post

    var button: some View {
        Button {} label: {
            Label((post.score ?? 0).formatted(), systemImage: "arrowtriangle.up")
                .fixedSize()
            #if os(iOS)
                .padding(.horizontal, .spacingSmall)
                .frame(minHeight: 32)
            #endif
        }
        #if !os(visionOS)
        .buttonStyle(.glass)
        #endif
        .disabled(true)
    }

    var body: some View {
        #if os(iOS) || os(macOS)
            GlassEffectContainer {
                button
            }
        #else
            button
        #endif
    }
}

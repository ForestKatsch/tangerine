//
//  Defaults.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/21/24.
//

import Defaults
import SwiftUI

// Stored by raw value: append new cases, never reorder.

enum LinkPreviewMode: Int, Identifiable, Defaults.Serializable, CaseIterable {
    case titleAndImage
    case title
    case linkOnly

    var id: Self { self }

    var label: LocalizedStringKey {
        switch self {
        case .titleAndImage: "link-preview-mode.title-and-image.label"
        case .title: "link-preview-mode.title.label"
        case .linkOnly: "link-preview-mode.link-only.label"
        }
    }
}

/// The colors of the bars that show how deep a comment is nested.
enum CommentPalette: Int, Identifiable, Defaults.Serializable, CaseIterable {
    case colorful
    case minimal

    var id: Self { self }

    var label: LocalizedStringKey {
        switch self {
        case .colorful: "comment-palette.colorful.label"
        case .minimal: "comment-palette.minimal.label"
        }
    }
}

extension Defaults.Keys {
    static let commentPalette = Key<CommentPalette>("commentPalette", default: .minimal)
    static let linkPreviewMode = Key<LinkPreviewMode>("linkPreviewMode", default: .titleAndImage)
}

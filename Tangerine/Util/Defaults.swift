//
//  Settings.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/21/24.
//

import Defaults
import Foundation
import SwiftUI

enum LinkPreviewMode: Int, Identifiable, Defaults.Serializable, CaseIterable {
    var id: Self { self }
    case titleAndImage
    case title
    case linkOnly
}

extension Defaults.Keys {
    static let commentTreeMode = Key<CommentTree.Mode>("commentTreeMode", default: .nested)
    static let commentPalette = Key<CommentTree.IndentPalette>("commentPalette", default: .minimal)

    static let linkPreviewMode = Key<LinkPreviewMode>("linkPreviewMode", default: .titleAndImage)
}

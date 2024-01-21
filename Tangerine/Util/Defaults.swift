//
//  Settings.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/21/24.
//

import Defaults
import Foundation

extension Defaults.Keys {
    static let commentTreeMode = Key<CommentTree.Mode>("commentTreeMode", default: .nested)
    static let commentPalette = Key<CommentTree.IndentPalette>("commentPalette", default: .minimal)
}

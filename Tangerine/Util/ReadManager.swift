//
//  ReadManager.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/13/25.
//

import SwiftUI

@Observable
class ReadManager {
    static let shared: ReadManager = .init()

    // Private set of visited IDs for O(1) lookup and insertion
    private var visitedIds: Set<AnyHashable> = []

    /// Checks if the item's ID has been visited
    func hasVisited(_ item: AnyHashable) -> Bool {
        visitedIds.contains(item)
    }

    /// Marks the item's ID as visited
    func markVisited(_ item: AnyHashable) {
        visitedIds.insert(item)
    }
}

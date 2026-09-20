//
//  File.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SwiftUI

@Observable
class API {
    static let shared = API()

    enum Endpoint: Hashable, Identifiable {
        var id: Self { self }
        case listing(ofType: ListingType)
    }

    // `String`-backed so a selected tab can round-trip through `@SceneStorage`.
    enum ListingType: String, Hashable, Identifiable, CaseIterable {
        var id: Self { self }
        case news
        case new
        case ask
        case show
        case jobs
    }

    var memorial: Bool = false
}

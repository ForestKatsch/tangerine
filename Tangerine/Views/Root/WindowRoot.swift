//
//  WindowRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/22/23.
//

import SwiftUI

struct WindowRoot: View {
    var body: some View {
        // TODO: differentiate on iPad as well?
        #if os(visionOS)
            TabRoot()
        #else
            ListingTab()
        #endif
    }
}

#Preview {
    WindowRoot()
}

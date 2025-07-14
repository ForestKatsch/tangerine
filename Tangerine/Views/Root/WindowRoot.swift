//
//  WindowRoot.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/22/23.
//

import SwiftUI

struct WindowRoot: View {
    var body: some View {
        #if os(visionOS)
            VisionTabRoot()
        #elseif os(macOS)
            ListingColumns()
        #else
            TabRoot()
        #endif
    }
}

#Preview {
    WindowRoot()
}

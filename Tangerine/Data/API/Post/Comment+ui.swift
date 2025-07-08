//
//  Comment+ui.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/7/25.
//

import SwiftUI

extension Comment {
    var opacity: CGFloat {
        guard let score = score else { return 1 }

        if score >= 0 { return 1 }
        if score <= -9 { return 0.1 }

        let alpha = 1.0 - (min(max(-CGFloat(score), 0), 9) / 9.0) * 0.9
        return alpha
    }

}

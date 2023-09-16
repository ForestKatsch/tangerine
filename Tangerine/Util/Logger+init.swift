//
//  Logger+init.swift
//  Pensieve
//
//  Created by Forest Katsch on 8/21/23.
//

import Foundation
import os

extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.identifier ?? "com.forestkatsch.tangerine", category: category)
    }
}

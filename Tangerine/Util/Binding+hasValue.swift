//
//  Binding+optionalBool.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/7/25.
//

import SwiftUI

extension Binding where Value == Bool {
    init(binding: Binding<(some Any)?>) {
        self.init(
            get: {
                binding.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }
                
                // We only handle `false` booleans to set our optional to `nil`
                // as we can't handle `true` for restoring the previous value.
                binding.wrappedValue = nil
            }
        )
    }
}

extension Binding {
    /// Maps an optional binding to a `Binding<Bool>`.
    /// This can be used to, for example, use an `Error?` object to decide whether or not to show an
    /// alert, without needing to rely on a separately handled `Binding<Bool>`.
    func hasValue<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        Binding<Bool>(binding: self)
    }
}

//
//  AccountScreen.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/21/24.
//

import Defaults
import SwiftUI

struct AccountScreen: View {
    var body: some View {
        SettingsView()
            .navigationTitle("account.title")
    }
}

#Preview {
    AccountScreen()
}

//
//  AccountScreen.swift
//  Tangerine
//
//  Created by Forest Katsch on 1/21/24.
//

import Defaults
import SwiftUI

struct SignInView: View {
    var body: some View {
        ContentUnavailableView("account-features.label", systemImage: "person.crop.circle", description: Text("coming-soon.message"))
            .frame(maxWidth: .infinity)
    }
}

struct AccountScreen: View {
    var body: some View {
        Form {
            Section {
                SignInView()
            }
            Section("settings.label") {
                ForEach(SettingsPage.Id.allCases) { page in
                    NavigationLink(page.label, value: page)
                }
            }
        }
        .navigationTitle("account.label")
        .navigationDestination(for: SettingsPage.Id.self) { page in
            SettingsPage(page: page)
        }
    }
}

#Preview {
    AccountScreen()
}

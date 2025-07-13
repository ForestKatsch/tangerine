//
//  SFSafariView.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/7/25.
//

import SafariServices
import SwiftUI

#if os(iOS)
    struct SFSafariView: UIViewControllerRepresentable {
        let url: URL

        func makeUIViewController(context _: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
            let viewController = SFSafariViewController(url: url)
            viewController.preferredControlTintColor = .accent
            return viewController
        }

        func updateUIViewController(_: SFSafariViewController, context _: UIViewControllerRepresentableContext<SFSafariView>) {
            // No need to do anything here
        }
    }
#endif

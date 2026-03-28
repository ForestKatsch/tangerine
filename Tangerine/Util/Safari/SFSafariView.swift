//
//  SFSafariView.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/7/25.
//

#if os(iOS)
    import SafariServices
    import SwiftUI

    struct SFSafariView: UIViewControllerRepresentable {
        let url: URL

        func makeUIViewController(context _: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
            let viewController = SFSafariViewController(url: url)
            return viewController
        }

        func updateUIViewController(_: SFSafariViewController, context _: UIViewControllerRepresentableContext<SFSafariView>) {
            // No need to do anything here
        }
    }
#endif

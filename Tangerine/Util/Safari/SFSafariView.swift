//
//  SFSafariView.swift
//  Tangerine
//
//  Created by Forest Katsch on 7/7/25.
//

import SwiftUI
import SafariServices

struct SFSafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        let viewController = SFSafariViewController(url: url)
        viewController.preferredControlTintColor = .accent
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariView>) {
        // No need to do anything here
    }
}

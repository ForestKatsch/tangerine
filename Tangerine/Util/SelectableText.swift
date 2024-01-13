//
//  SelectableText.swift
//  Tangerine
//
//  Created by Forest Katsch on 9/14/23.
//

import Foundation
import SwiftUI
// import UIKit

/*
 struct SelectableText: UIViewRepresentable {
     var text: String

     func makeUIView(context: Context) -> UITextView {
         let textView = UITextView()
         textView.isEditable = false // Set to true if you want it to be editable
         textView.isSelectable = true // Enable text selection
         textView.font = UIFont.preferredFont(forTextStyle: .body)
         //textView.delegate = context.coordinator
         return textView
     }

     func updateUIView(_ textView: UITextView, context: Context) {
         textView.text = text
     }

     /*
      func makeCoordinator() -> Coordinator {
      Coordinator(self)
      }
      */

     /*
      class Coordinator: NSObject, UITextViewDelegate {
      var parent: TextViewWrapper

      init(_ parent: TextViewWrapper) {
      self.parent = parent
      }

      func textViewDidChange(_ textView: UITextView) {
      parent.text = textView.text
      }
      }
      */
 }
 */

struct SelectableText: View {
    var text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        TextField(text: Binding(get: { text }, set: { _, _ in })) {}
            .textFieldStyle(.plain)
            .disabled(true)
    }
}

// Example-iOS-SwiftUI

import SwiftUI

struct RichTextHostView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ExampleViewController {
        ExampleViewController()
    }

    func updateUIViewController(_ uiViewController: ExampleViewController, context: Context) {
        // No-op. VC manages its own fetching & updates.
    }
}

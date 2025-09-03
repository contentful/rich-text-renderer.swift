// Example-iOS-SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var showModal = false
        @State private var showNavModal = false

        var body: some View {
            VStack(spacing: 20) {
                Button("Present Modally") {
                    showModal = true
                }

                Button("Present in Navigation Controller") {
                    showNavModal = true
                }
            }
            .sheet(isPresented: $showModal) {
                RichTextHostView() // UIKit-hosted ViewController
            }
            .fullScreenCover(isPresented: $showNavModal) {
                NavigationView {
                    RichTextHostView()
                        .navigationBarTitle("Betonowy Dom.", displayMode: .inline)
                }
            }
        }
}

#Preview {
    ContentView()
}

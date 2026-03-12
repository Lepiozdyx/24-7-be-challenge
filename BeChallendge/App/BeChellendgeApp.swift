import SwiftUI

@main
struct BeChellendgeApp: App {
    var body: some Scene {
        WindowGroup {
            LoadingScreen()
                .preferredColorScheme(.light)
        }
    }
}

#Preview {
    LoadingScreen()
}

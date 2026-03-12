import SwiftUI

struct AppContentView: View {
    
    @StateObject private var manager = StateManager()
        
    var body: some View {
        Group {
            switch manager.appState {
            case .request:
                LoadingView()
                
            case .support:
                if let url = manager.networkManager.challengeURL {
                    WKWebViewManager(
                        url: url,
                        webManager: manager.networkManager
                    )
                } else {
                    WKWebViewManager(
                        url: NetworkManager.initialURL,
                        webManager: manager.networkManager
                    )
                }
                
            case .loading:
                LoadingScreen()
                    .preferredColorScheme(.light)
            }
        }
        .onAppear {
            manager.stateRequest()
        }
    }
}

#Preview {
    AppContentView()
}

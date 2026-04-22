import SwiftUI
import Foundation

struct LoadingScreen: View {
    @State private var showSplash = false
    @State private var isWebViewNeeded: Bool = false
    @State private var isFirstLaunch: Bool = UserDefaults.standard.isFirstLaunch
    
    func handleFirstLaunchEnd() {
        UserDefaults.standard.isFirstLaunch = false
        isFirstLaunch = false
    }
    
    var body: some View {
        if showSplash {
            
        } else {
            if isFirstLaunch {
                ZStack {
                    OnboardView {
                        handleFirstLaunchEnd()
                    }
                }
                .ignoresSafeArea()
            } else {
                if isWebViewNeeded {
                    
                } else {
                    TabBarView()
                }
            }
        }
    }
}

extension UserDefaults {
    private enum Keys {
        static let hasLaunched = "hasLaunched"
    }
    var isFirstLaunch: Bool {
        get {
            !bool(forKey: Keys.hasLaunched)
        }
        set {
            set(!newValue, forKey: Keys.hasLaunched)
        }
    }
}

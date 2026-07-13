import SwiftUI

@main
struct KiteCloneApp: App {
    @StateObject private var session = SessionStore()
    @StateObject private var market = MarketDataService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(market)
                .preferredColorScheme(.light)
        }
    }
}

/// Switches between the login flow and the authenticated app.
struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            if session.isAuthenticated {
                MainTabView()
                    .transition(.opacity)
            } else {
                LoginFlowView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.isAuthenticated)
    }
}

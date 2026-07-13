import SwiftUI
import UIKit

/// The authenticated app shell, mirroring Kite's five bottom tabs.
struct MainTabView: View {
    init() {
        // Match Kite's clean white tab bar / nav bar chrome.
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.white
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.white
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    var body: some View {
        TabView {
            WatchlistView()
                .tabItem { Label("Watchlist", systemImage: "line.3.horizontal") }

            OrdersView()
                .tabItem { Label("Orders", systemImage: "doc.text") }

            PortfolioView()
                .tabItem { Label("Portfolio", systemImage: "briefcase") }

            BidsView()
                .tabItem { Label("Bids", systemImage: "hand.raised") }

            AccountView()
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
        .tint(KiteTheme.brand)
    }
}

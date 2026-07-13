import SwiftUI

/// Orders tab — an empty state, matching a fresh Kite account.
struct OrdersView: View {
    var body: some View {
        NavigationStack {
            EmptyStateView(
                icon: "doc.text",
                title: "No orders",
                message: "Orders you place will appear here."
            )
            .navigationTitle("Orders")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// Bids tab — an empty state (IPOs / auctions).
struct BidsView: View {
    var body: some View {
        NavigationStack {
            EmptyStateView(
                icon: "hand.raised",
                title: "No bids",
                message: "IPO and auction bids will show up here."
            )
            .navigationTitle("Bids")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// Reusable empty-state placeholder.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(KiteTheme.textSecondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(KiteTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(KiteTheme.background)
    }
}

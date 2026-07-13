import SwiftUI

/// Account tab — profile summary and logout.
struct AccountView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileHeader
                        .padding(.top, 8)

                    section {
                        row(icon: "person.text.rectangle", title: "User ID", value: session.displayName)
                        Divider().background(KiteTheme.separator)
                        row(icon: "building.columns", title: "Demat", value: "1208160000000000")
                        Divider().background(KiteTheme.separator)
                        row(icon: "envelope", title: "Email", value: "\(session.displayName.lowercased())@example.com")
                    }

                    section {
                        linkRow(icon: "gearshape", title: "Settings")
                        Divider().background(KiteTheme.separator)
                        linkRow(icon: "questionmark.circle", title: "Support")
                        Divider().background(KiteTheme.separator)
                        linkRow(icon: "lock.shield", title: "Security")
                    }

                    Button(role: .destructive) {
                        session.logout()
                    } label: {
                        Text("Logout")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(KiteTheme.card, in: RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(KiteTheme.loss)
                    }

                    Text("Kite clone · demo build")
                        .font(.caption)
                        .foregroundStyle(KiteTheme.textSecondary)
                }
                .padding(16)
            }
            .background(KiteTheme.background)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(KiteTheme.brand.opacity(0.12)).frame(width: 56, height: 56)
                Text(String(session.displayName.prefix(1)))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(KiteTheme.brand)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(session.displayName)
                    .font(.headline)
                Text("Equity · F&O")
                    .font(.subheadline)
                    .foregroundStyle(KiteTheme.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(KiteTheme.card, in: RoundedRectangle(cornerRadius: 10))
    }

    private func section<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(KiteTheme.card, in: RoundedRectangle(cornerRadius: 10))
    }

    private func row(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(KiteTheme.textSecondary)
                .frame(width: 24)
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(KiteTheme.textSecondary)
                .font(.subheadline)
        }
        .padding(14)
    }

    private func linkRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(KiteTheme.textSecondary)
                .frame(width: 24)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(KiteTheme.textSecondary)
        }
        .padding(14)
        .contentShape(Rectangle())
    }
}

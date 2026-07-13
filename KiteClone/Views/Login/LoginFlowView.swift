import SwiftUI

/// Coordinates the two-step Kite login: credentials, then a 6-digit PIN.
struct LoginFlowView: View {
    enum Step { case credentials, pin }

    @State private var step: Step = .credentials

    var body: some View {
        ZStack {
            KiteTheme.background.ignoresSafeArea()
            switch step {
            case .credentials:
                CredentialsView { withAnimation { step = .pin } }
                    .transition(.move(edge: .leading).combined(with: .opacity))
            case .pin:
                PinView(onBack: { withAnimation { step = .credentials } })
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
}

/// The Kite logo lockup used on the login screens.
struct KiteLogo: View {
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(KiteTheme.brand)
                    .frame(width: 34, height: 34)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text("kite")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(KiteTheme.textPrimary)
        }
    }
}

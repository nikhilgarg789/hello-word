import SwiftUI

/// Coordinates the Kite login: Face ID auto-login by default, with a User ID /
/// password fallback. No PIN / MFA step.
struct LoginFlowView: View {
    enum Step { case biometric, credentials }

    @State private var step: Step = .biometric

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            switch step {
            case .biometric:
                BiometricLoginView(onUseCredentials: { withAnimation { step = .credentials } })
                    .transition(.opacity)
            case .credentials:
                CredentialsView(onUseBiometrics: { withAnimation { step = .biometric } })
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
}

/// The stylised Zerodha "kite" mark drawn as a vector.
struct KiteMark: View {
    var size: CGFloat = 40

    var body: some View {
        Canvas { context, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            let top = CGPoint(x: w * 0.5, y: 0)
            let left = CGPoint(x: w * 0.14, y: h * 0.34)
            let right = CGPoint(x: w * 0.86, y: h * 0.34)
            let mid = CGPoint(x: w * 0.5, y: h * 0.52)
            let bottom = CGPoint(x: w * 0.5, y: h * 0.78)

            // Kite body: two upper panels + two lower panels around the spine.
            var body = Path()
            body.move(to: top)
            body.addLine(to: left)
            body.addLine(to: bottom)
            body.addLine(to: right)
            body.closeSubpath()
            context.fill(body, with: .color(KiteTheme.brand))

            // Struts (spine + cross bar) in white.
            var struts = Path()
            struts.move(to: top); struts.addLine(to: bottom)
            struts.move(to: left); struts.addLine(to: right)
            context.stroke(struts, with: .color(.white), lineWidth: max(1, w * 0.03))

            // Little mid highlight to give the kite two-tone depth.
            var lower = Path()
            lower.move(to: mid)
            lower.addLine(to: left)
            lower.addLine(to: bottom)
            lower.closeSubpath()
            lower.move(to: mid)
            lower.addLine(to: right)
            lower.addLine(to: bottom)
            lower.closeSubpath()
            context.fill(lower, with: .color(KiteTheme.brand.opacity(0.75)))

            // Tail with two bows.
            var tail = Path()
            tail.move(to: bottom)
            tail.addQuadCurve(
                to: CGPoint(x: w * 0.62, y: h * 0.98),
                control: CGPoint(x: w * 0.40, y: h * 0.90))
            context.stroke(tail, with: .color(KiteTheme.brand), lineWidth: max(1, w * 0.03))
        }
        .frame(width: size, height: size)
    }
}

/// Full logo lockup used on the login screens.
struct KiteLogo: View {
    var body: some View {
        HStack(spacing: 10) {
            KiteMark(size: 40)
            VStack(alignment: .leading, spacing: -2) {
                Text("Kite")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(KiteTheme.textPrimary)
                Text("by Zerodha")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(KiteTheme.textSecondary)
            }
        }
    }
}

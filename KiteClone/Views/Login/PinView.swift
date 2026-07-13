import SwiftUI

/// Step 2 of login: a 6-digit PIN. Any 6 digits are accepted.
struct PinView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var pin = ""
    @State private var error: String?
    @FocusState private var focused: Bool

    var onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(KiteTheme.textPrimary)
                }
                Spacer()
            }

            KiteLogo()

            VStack(alignment: .leading, spacing: 4) {
                Text("Enter PIN")
                    .font(.title3.weight(.semibold))
                Text("Signed in as \(session.displayName)")
                    .font(.subheadline)
                    .foregroundStyle(KiteTheme.textSecondary)
            }

            // Six PIN boxes driven by a hidden text field.
            ZStack {
                TextField("", text: $pin)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .opacity(0.01)
                    .onChange(of: pin) { _, newValue in
                        pin = String(newValue.filter(\.isNumber).prefix(6))
                        error = nil
                        if pin.count == 6 { submit() }
                    }

                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        PinBox(filled: index < pin.count)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { focused = true }
            }

            if let error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(KiteTheme.loss)
            }

            Button(action: submit) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(KiteTheme.brand, in: RoundedRectangle(cornerRadius: 6))
                    .foregroundStyle(.white)
            }

            Text("Demo build — enter any 6 digits.")
                .font(.footnote)
                .foregroundStyle(KiteTheme.textSecondary)

            Spacer()
        }
        .padding(24)
        .onAppear { focused = true }
    }

    private func submit() {
        if let message = session.validatePIN(pin) {
            error = message
        }
    }
}

private struct PinBox: View {
    let filled: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .stroke(filled ? KiteTheme.brand : KiteTheme.separator, lineWidth: 1.5)
            .frame(width: 44, height: 52)
            .overlay {
                if filled {
                    Circle()
                        .fill(KiteTheme.textPrimary)
                        .frame(width: 10, height: 10)
                }
            }
    }
}

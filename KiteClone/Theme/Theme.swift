import SwiftUI

/// Central place for Kite-like colors, fonts and formatters so the whole app
/// stays visually consistent.
enum KiteTheme {

    // MARK: Brand & semantic colors

    /// Kite's signature deep-orange brand color.
    static let brand = Color(hex: 0xFF5722)

    /// Buy actions are blue in Kite.
    static let buyBlue = Color(hex: 0x4184F3)

    /// Sell actions are orange/red in Kite.
    static let sellOrange = Color(hex: 0xFF5B29)

    /// Gains.
    static let gain = Color(hex: 0x4CAF50)

    /// Losses.
    static let loss = Color(hex: 0xE84142)

    // MARK: Surfaces

    static let background = Color(hex: 0xF5F5F5)
    static let card = Color.white
    static let separator = Color(hex: 0xEDEDED)
    static let field = Color(hex: 0xF3F3F3)

    // MARK: Text

    static let textPrimary = Color(hex: 0x30302F)
    static let textSecondary = Color(hex: 0x9AA0A6)

    /// Returns green for non-negative values, red otherwise.
    static func pnlColor(_ value: Double) -> Color {
        value < 0 ? loss : gain
    }

    /// Momentary highlight tint used when a price ticks (Kite flashes rows).
    static func flash(up: Bool) -> Color {
        (up ? gain : loss).opacity(0.16)
    }
}

// MARK: - Formatting helpers

enum Format {
    /// Indian-style number formatting with grouping, e.g. 1,23,456.75
    static func currency(_ value: Double, decimals: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
    }

    /// Signed value with an explicit + or − prefix.
    static func signed(_ value: Double, decimals: Int = 2) -> String {
        let sign = value < 0 ? "-" : "+"
        return sign + currency(abs(value), decimals: decimals)
    }

    static func signedPercent(_ value: Double) -> String {
        let sign = value < 0 ? "-" : "+"
        return sign + String(format: "%.2f%%", abs(value))
    }
}

// MARK: - Color hex convenience

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

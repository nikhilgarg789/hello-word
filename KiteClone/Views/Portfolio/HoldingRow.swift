import SwiftUI

/// A single holding row showing quantity, average cost, live LTP and live P&L —
/// laid out like Kite's holdings list.
struct HoldingRow: View {
    @EnvironmentObject private var market: MarketDataService
    let holding: Holding

    var body: some View {
        let ltp = market.lastPrice(for: holding.symbol)
        let pnl = holding.pnl(ltp: ltp)
        let pnlPct = holding.pnlPercent(ltp: ltp)
        let prevClose = SeedData.instrument(for: holding.symbol)?.previousClose ?? holding.averagePrice
        let dayChangePct = prevClose == 0 ? 0 : ((ltp - prevClose) / prevClose) * 100
        let pnlColor = KiteTheme.pnlColor(pnl)

        VStack(spacing: 8) {
            HStack {
                Text(holding.symbol)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(Format.signed(pnl))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(pnlColor)
                    .monospacedDigit()
            }

            HStack {
                Text("Qty. \(holding.quantity)  ·  Avg. \(Format.currency(holding.averagePrice))")
                    .font(.caption)
                    .foregroundStyle(KiteTheme.textSecondary)
                Spacer()
                Text(Format.signedPercent(pnlPct))
                    .font(.caption)
                    .foregroundStyle(pnlColor)
                    .monospacedDigit()
            }

            HStack {
                Text("Invested \(Format.currency(holding.invested))")
                    .font(.caption2)
                    .foregroundStyle(KiteTheme.textSecondary)
                Spacer()
                HStack(spacing: 4) {
                    Text("LTP \(Format.currency(ltp))")
                        .font(.caption2)
                        .foregroundStyle(KiteTheme.textSecondary)
                    Text("(\(Format.signedPercent(dayChangePct)))")
                        .font(.caption2)
                        .foregroundStyle(KiteTheme.pnlColor(dayChangePct))
                }
                .monospacedDigit()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

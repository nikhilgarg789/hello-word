import SwiftUI

/// A single holding row, laid out like Kite's holdings list: symbol + net P&L
/// on top, quantity/average and live LTP + day change beneath.
struct HoldingRow: View {
    @EnvironmentObject private var market: MarketDataService
    let holding: Holding

    var body: some View {
        let ltp = market.lastPrice(for: holding.symbol)
        let pnl = holding.pnl(ltp: ltp)
        let pnlPct = holding.pnlPercent(ltp: ltp)
        let prevClose = market.previousClose(for: holding.symbol)
        let dayChangePct = prevClose == 0 ? 0 : ((ltp - prevClose) / prevClose) * 100
        let pnlColor = KiteTheme.pnlColor(pnl)

        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(holding.symbol)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(KiteTheme.textPrimary)
                Spacer()
                Text("\(Format.signed(pnl))  (\(Format.signedPercent(pnlPct)))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(pnlColor)
                    .monospacedDigit()
            }

            HStack(alignment: .firstTextBaseline) {
                Text("Qty. \(holding.quantity)  ·  Avg. \(Format.currency(holding.averagePrice))")
                    .font(.system(size: 12))
                    .foregroundStyle(KiteTheme.textSecondary)
                Spacer()
                HStack(spacing: 5) {
                    Text("LTP \(Format.currency(ltp))")
                        .foregroundStyle(KiteTheme.textSecondary)
                    Text("(\(Format.signedPercent(dayChangePct)))")
                        .foregroundStyle(KiteTheme.pnlColor(dayChangePct))
                }
                .font(.system(size: 12))
                .monospacedDigit()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(KiteTheme.card)
    }
}

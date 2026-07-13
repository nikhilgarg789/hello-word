import SwiftUI

/// A lightweight quote sheet shown when tapping a watchlist row, with mock
/// Buy / Sell actions (Kite shows these when you tap a stock).
struct InstrumentDetailView: View {
    @EnvironmentObject private var market: MarketDataService
    @Environment(\.dismiss) private var dismiss
    let instrument: Instrument

    var body: some View {
        let quote = market.quote(for: instrument.symbol)
        let ltp = quote?.lastPrice ?? instrument.previousClose
        let change = quote?.change ?? 0
        let pct = quote?.changePercent ?? 0
        let color = KiteTheme.pnlColor(change)

        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(instrument.name)
                        .font(.title3.weight(.semibold))
                    Text("\(instrument.symbol) · \(instrument.exchange)")
                        .font(.subheadline)
                        .foregroundStyle(KiteTheme.textSecondary)
                }

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(Format.currency(ltp))
                        .font(.system(size: 34, weight: .bold))
                        .monospacedDigit()
                    Text("\(Format.signed(change)) (\(Format.signedPercent(pct)))")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(color)
                        .monospacedDigit()
                }

                statsGrid(quote: quote, ltp: ltp)

                Spacer()

                HStack(spacing: 12) {
                    actionButton("BUY", color: KiteTheme.buyBlue)
                    actionButton("SELL", color: KiteTheme.sellOrange)
                }
            }
            .padding(20)
            .background(KiteTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func statsGrid(quote: Quote?, ltp: Double) -> some View {
        let prevClose = quote?.previousClose ?? instrument.previousClose
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            stat("Prev. Close", Format.currency(prevClose))
            stat("Last Price", Format.currency(ltp))
            stat("Day High", Format.currency(max(ltp, prevClose) * 1.004))
            stat("Day Low", Format.currency(min(ltp, prevClose) * 0.996))
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(KiteTheme.textSecondary)
            Text(value)
                .font(.subheadline.weight(.medium))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(KiteTheme.card, in: RoundedRectangle(cornerRadius: 8))
    }

    private func actionButton(_ title: String, color: Color) -> some View {
        Button { dismiss() } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color, in: RoundedRectangle(cornerRadius: 6))
                .foregroundStyle(.white)
        }
    }
}

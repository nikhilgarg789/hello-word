import SwiftUI

/// The Portfolio (Holdings) tab: a fixed set of holdings whose current value,
/// day's change and total P&L are computed live from `MarketDataService`.
struct PortfolioView: View {
    @EnvironmentObject private var market: MarketDataService

    private let holdings = SeedData.holdings

    private var invested: Double { holdings.reduce(0) { $0 + $1.invested } }

    private var currentValue: Double {
        holdings.reduce(0) { $0 + $1.currentValue(ltp: market.lastPrice(for: $1.symbol)) }
    }

    private var totalPnl: Double { currentValue - invested }

    private var totalPnlPercent: Double {
        invested == 0 ? 0 : (totalPnl / invested) * 100
    }

    private var dayPnl: Double {
        holdings.reduce(0) { sum, h in
            sum + h.dayPnl(ltp: market.lastPrice(for: h.symbol),
                           previousClose: market.previousClose(for: h.symbol))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    summaryCard
                        .padding(16)

                    HStack {
                        Text("HOLDINGS (\(holdings.count))")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(KiteTheme.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                    LazyVStack(spacing: 0) {
                        ForEach(holdings) { holding in
                            HoldingRow(holding: holding)
                            Divider().padding(.leading, 16)
                        }
                    }
                    .background(KiteTheme.card)
                }
            }
            .background(KiteTheme.background)
            .navigationTitle("Holdings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Summary card

    private var summaryCard: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top) {
                metric(title: "Invested", value: invested, alignment: .leading)
                Spacer()
                metric(title: "Current", value: currentValue, alignment: .trailing)
            }

            Divider()

            HStack {
                Text("P&L")
                    .font(.system(size: 13))
                    .foregroundStyle(KiteTheme.textSecondary)
                Spacer()
                Text("\(Format.signed(totalPnl))   \(Format.signedPercent(totalPnlPercent))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(KiteTheme.pnlColor(totalPnl))
                    .monospacedDigit()
            }

            Divider()

            HStack {
                Text("Day's P&L")
                    .font(.system(size: 13))
                    .foregroundStyle(KiteTheme.textSecondary)
                Spacer()
                Text(Format.signed(dayPnl))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(KiteTheme.pnlColor(dayPnl))
                    .monospacedDigit()
            }
        }
        .padding(16)
        .background(KiteTheme.card, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(KiteTheme.separator, lineWidth: 1))
    }

    private func metric(title: String, value: Double, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(KiteTheme.textSecondary)
            Text("₹\(Format.currency(value))")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(KiteTheme.textPrimary)
                .monospacedDigit()
        }
    }
}

import SwiftUI

/// The Portfolio tab: a fixed set of holdings whose current value, day's change
/// and total P&L are all computed live from `MarketDataService` prices.
struct PortfolioView: View {
    @EnvironmentObject private var market: MarketDataService

    private let holdings = SeedData.holdings

    // MARK: Aggregates (recomputed on every price tick)

    private var invested: Double {
        holdings.reduce(0) { $0 + $1.invested }
    }

    private var currentValue: Double {
        holdings.reduce(0) { $0 + $1.currentValue(ltp: market.lastPrice(for: $1.symbol)) }
    }

    private var totalPnl: Double { currentValue - invested }

    private var totalPnlPercent: Double {
        invested == 0 ? 0 : (totalPnl / invested) * 100
    }

    private var dayPnl: Double {
        holdings.reduce(0) { sum, h in
            let prevClose = SeedData.instrument(for: h.symbol)?.previousClose ?? h.averagePrice
            return sum + h.dayPnl(ltp: market.lastPrice(for: h.symbol), previousClose: prevClose)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    summaryCard
                        .padding(16)

                    HStack {
                        Text("Holdings (\(holdings.count))")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(KiteTheme.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                    LazyVStack(spacing: 0) {
                        ForEach(holdings) { holding in
                            HoldingRow(holding: holding)
                            Divider().background(KiteTheme.separator)
                        }
                    }
                    .background(KiteTheme.card)
                }
            }
            .background(KiteTheme.background)
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Summary card

    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                metric(title: "Invested", value: Format.currency(invested), color: KiteTheme.textPrimary)
                Spacer()
                metric(title: "Current", value: Format.currency(currentValue), color: KiteTheme.textPrimary, alignment: .trailing)
            }

            Divider().background(KiteTheme.separator)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Day's P&L")
                        .font(.caption)
                        .foregroundStyle(KiteTheme.textSecondary)
                    Text(Format.signed(dayPnl))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KiteTheme.pnlColor(dayPnl))
                        .monospacedDigit()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total P&L")
                        .font(.caption)
                        .foregroundStyle(KiteTheme.textSecondary)
                    Text("\(Format.signed(totalPnl))  (\(Format.signedPercent(totalPnlPercent)))")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KiteTheme.pnlColor(totalPnl))
                        .monospacedDigit()
                }
            }
        }
        .padding(16)
        .background(KiteTheme.card, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(KiteTheme.separator, lineWidth: 1)
        )
    }

    private func metric(title: String, value: String, color: Color, alignment: HorizontalAlignment = .leading) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(KiteTheme.textSecondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
                .monospacedDigit()
        }
    }
}

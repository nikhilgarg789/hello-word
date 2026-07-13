import SwiftUI

/// The first tab: a searchable list of instruments with live prices.
struct WatchlistView: View {
    @EnvironmentObject private var market: MarketDataService
    @State private var search = ""
    @State private var selected: Instrument?

    private var instruments: [Instrument] {
        let all = SeedData.watchlistSymbols.compactMap { SeedData.instrument(for: $0) }
        guard !search.isEmpty else { return all }
        let q = search.uppercased()
        return all.filter { $0.symbol.contains(q) || $0.name.uppercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(instruments) { instrument in
                        Button { selected = instrument } label: {
                            InstrumentRow(instrument: instrument)
                        }
                        .buttonStyle(.plain)
                        Divider().background(KiteTheme.separator)
                    }
                }
                .background(KiteTheme.card)
            }
            .background(KiteTheme.background)
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(instruments.count) / 50")
                        .font(.footnote)
                        .foregroundStyle(KiteTheme.textSecondary)
                }
            }
            .searchable(text: $search, prompt: "Search & add")
            .sheet(item: $selected) { InstrumentDetailView(instrument: $0) }
        }
    }
}

/// A single live watchlist row: symbol on the left, LTP + change on the right.
struct InstrumentRow: View {
    @EnvironmentObject private var market: MarketDataService
    let instrument: Instrument

    var body: some View {
        let quote = market.quote(for: instrument.symbol)
        let ltp = quote?.lastPrice ?? instrument.previousClose
        let change = quote?.change ?? 0
        let pct = quote?.changePercent ?? 0
        let color = KiteTheme.pnlColor(change)

        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(instrument.symbol)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(color)
                Text(instrument.exchange)
                    .font(.caption2)
                    .foregroundStyle(KiteTheme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(Format.currency(ltp))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
                    .monospacedDigit()
                HStack(spacing: 6) {
                    Image(systemName: change < 0 ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                        .font(.system(size: 8))
                    Text("\(Format.signed(change)) (\(Format.signedPercent(pct)))")
                        .font(.caption2)
                        .monospacedDigit()
                }
                .foregroundStyle(color)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

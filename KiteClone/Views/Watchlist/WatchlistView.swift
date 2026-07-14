import SwiftUI

/// The first tab: Kite-style watchlist with a search field, the 1–7 watchlist
/// switcher pinned above the tab bar, and live price rows.
struct WatchlistView: View {
    @EnvironmentObject private var market: MarketDataService
    @State private var search = ""
    @State private var selectedWatchlist = 1
    @State private var expandedSymbol: String?

    private var instruments: [Instrument] {
        let all = SeedData.watchlistSymbols.compactMap { SeedData.instrument(for: $0) }
        guard !search.isEmpty else { return all }
        let q = search.uppercased()
        return all.filter { $0.symbol.contains(q) || $0.name.uppercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                Divider()
                countHeader
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(instruments) { instrument in
                            InstrumentRow(
                                instrument: instrument,
                                isExpanded: expandedSymbol == instrument.symbol,
                                onTap: { toggle(instrument.symbol) }
                            )
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
            .background(KiteTheme.card)
            .navigationTitle("")
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) { watchlistSwitcher }
        }
    }

    private func toggle(_ symbol: String) {
        withAnimation(.easeInOut(duration: 0.18)) {
            expandedSymbol = expandedSymbol == symbol ? nil : symbol
        }
    }

    // MARK: Search bar + live indicator

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundStyle(KiteTheme.textSecondary)
                TextField("Search & add", text: $search)
                    .font(.system(size: 15))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                if !search.isEmpty {
                    Button { search = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(KiteTheme.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(KiteTheme.field, in: RoundedRectangle(cornerRadius: 6))

            liveBadge
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var liveBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(market.isLive ? KiteTheme.gain : KiteTheme.textSecondary)
                .frame(width: 7, height: 7)
            Text(market.isLive ? "live" : "sim")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(KiteTheme.textSecondary)
        }
    }

    private var countHeader: some View {
        HStack {
            Text("\(instruments.count) / 50")
                .font(.system(size: 12))
                .foregroundStyle(KiteTheme.textSecondary)
            Spacer()
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 12))
                .foregroundStyle(KiteTheme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(KiteTheme.card)
    }

    // MARK: 1–7 watchlist switcher (pinned above the tab bar, like Kite)

    private var watchlistSwitcher: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(1...7, id: \.self) { index in
                    Button { selectedWatchlist = index } label: {
                        Text("\(index)")
                            .font(.system(size: 14, weight: selectedWatchlist == index ? .semibold : .regular))
                            .foregroundStyle(selectedWatchlist == index ? KiteTheme.brand : KiteTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(alignment: .bottom) {
                                if selectedWatchlist == index {
                                    Rectangle().fill(KiteTheme.brand).frame(height: 2)
                                }
                            }
                    }
                }
            }
        }
        .background(KiteTheme.card)
    }
}

/// A single live watchlist row with a price-flash highlight and an inline
/// BUY / SELL action strip that expands on tap.
struct InstrumentRow: View {
    @EnvironmentObject private var market: MarketDataService
    let instrument: Instrument
    let isExpanded: Bool
    let onTap: () -> Void

    @State private var flash: Color = .clear
    @State private var lastSeenPrice: Double?

    var body: some View {
        let quote = market.quote(for: instrument.symbol)
        let ltp = quote?.lastPrice ?? instrument.previousClose
        let change = quote?.change ?? 0
        let pct = quote?.changePercent ?? 0
        let color = KiteTheme.pnlColor(change)

        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(instrument.symbol)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(KiteTheme.textPrimary)
                        Text(instrument.exchange)
                            .font(.system(size: 10))
                            .foregroundStyle(KiteTheme.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(Format.currency(ltp))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(color)
                            .monospacedDigit()
                        HStack(spacing: 4) {
                            Image(systemName: change < 0 ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                                .font(.system(size: 7))
                            Text("\(Format.signed(change))  (\(Format.signedPercent(pct)))")
                                .font(.system(size: 11))
                                .monospacedDigit()
                        }
                        .foregroundStyle(color)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(flash)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                actionStrip
            }
        }
        .onChange(of: ltp) { oldValue, newValue in
            guard newValue != oldValue else { return }
            flash = KiteTheme.flash(up: newValue >= oldValue)
            withAnimation(.easeOut(duration: 0.6)) { flash = .clear }
        }
    }

    private var actionStrip: some View {
        HStack(spacing: 10) {
            actionButton("B", color: KiteTheme.buyBlue)
            actionButton("S", color: KiteTheme.sellOrange)
            Spacer()
            iconButton("chart.bar.xaxis")
            iconButton("info.circle")
            iconButton("trash")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(KiteTheme.field)
    }

    private func actionButton(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 32)
            .background(color, in: RoundedRectangle(cornerRadius: 4))
    }

    private func iconButton(_ system: String) -> some View {
        Image(systemName: system)
            .font(.system(size: 16))
            .foregroundStyle(KiteTheme.textSecondary)
            .frame(width: 36, height: 32)
    }
}

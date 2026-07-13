import Foundation

/// A tradable company / instrument shown on the watchlist.
struct Instrument: Identifiable, Hashable {
    let id = UUID()
    /// Trading symbol, e.g. "RELIANCE".
    let symbol: String
    /// Human readable company name.
    let name: String
    /// Exchange, e.g. "NSE".
    let exchange: String
    /// Reference/previous-close price used to compute the day's change.
    let previousClose: Double
}

/// A live quote for a symbol, produced by `MarketDataService`.
struct Quote: Hashable {
    let symbol: String
    /// Last traded price.
    var lastPrice: Double
    /// Previous close, used as the day's reference.
    let previousClose: Double

    /// Absolute change vs previous close.
    var change: Double { lastPrice - previousClose }

    /// Percentage change vs previous close.
    var changePercent: Double {
        guard previousClose != 0 else { return 0 }
        return (change / previousClose) * 100
    }
}

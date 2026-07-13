import Foundation
import Combine

/// Publishes live-updating quotes for every seeded instrument.
///
/// This demo generates prices with a small random walk around each instrument's
/// previous close, updating a few times per second so the watchlist and the
/// portfolio P&L visibly move. To use real market data, replace `tick()` with a
/// network fetch that updates `quotes[symbol]?.lastPrice`.
final class MarketDataService: ObservableObject {

    static let shared = MarketDataService()

    /// Latest quote per symbol.
    @Published private(set) var quotes: [String: Quote] = [:]

    private var timer: AnyCancellable?

    private init() {
        // Seed each quote at its previous close, then nudge slightly so the
        // opening screen doesn't show a flat 0.00% for everything.
        for instrument in SeedData.instruments {
            let jitter = Double.random(in: -0.006...0.010) // -0.6%..+1.0%
            let start = instrument.previousClose * (1 + jitter)
            quotes[instrument.symbol] = Quote(
                symbol: instrument.symbol,
                lastPrice: (start * 100).rounded() / 100,
                previousClose: instrument.previousClose
            )
        }
    }

    /// Begin streaming simulated price updates.
    func start() {
        guard timer == nil else { return }
        timer = Timer.publish(every: 1.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    /// Stop streaming (e.g. on logout).
    func stop() {
        timer?.cancel()
        timer = nil
    }

    /// Convenience accessor with a sensible fallback.
    func lastPrice(for symbol: String) -> Double {
        quotes[symbol]?.lastPrice
            ?? SeedData.instrument(for: symbol)?.previousClose
            ?? 0
    }

    func quote(for symbol: String) -> Quote? { quotes[symbol] }

    /// Advance every quote by one small random step, mean-reverting gently
    /// toward the previous close so prices stay realistic over time.
    private func tick() {
        for (symbol, quote) in quotes {
            let prev = quote.previousClose
            // Random step scaled to price, plus a small pull back toward prev.
            let drift = (prev - quote.lastPrice) * 0.02
            let noise = quote.lastPrice * Double.random(in: -0.0015...0.0015)
            var newPrice = quote.lastPrice + drift + noise
            newPrice = max(newPrice, prev * 0.5) // never collapse to zero
            var updated = quote
            updated.lastPrice = (newPrice * 100).rounded() / 100
            quotes[symbol] = updated
        }
    }
}

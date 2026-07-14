import Foundation
import Combine

/// Publishes live quotes for every seeded instrument.
///
/// Primary source: Yahoo Finance's public, keyless chart endpoint
/// (`query1.finance.yahoo.com/v8/finance/chart/<SYMBOL>.NS`), polled a few
/// seconds apart. NSE symbols map to Yahoo by appending ".NS" (e.g.
/// "RELIANCE" -> "RELIANCE.NS").
///
/// If the network is unavailable or Yahoo can't be reached, the service falls
/// back to a small simulated random walk so the UI never looks frozen.
@MainActor
final class MarketDataService: ObservableObject {

    static let shared = MarketDataService()

    /// Latest quote per (our) symbol.
    @Published private(set) var quotes: [String: Quote] = [:]

    /// True once at least one real quote has been fetched from Yahoo.
    @Published private(set) var isLive = false

    /// How often to poll for fresh prices.
    private let refreshInterval: TimeInterval = 5

    private var pollTask: Task<Void, Never>?
    private var simulationTimer: AnyCancellable?

    private init() {
        // Seed each quote at its previous close so the first frame has data.
        for instrument in SeedData.instruments {
            quotes[instrument.symbol] = Quote(
                symbol: instrument.symbol,
                lastPrice: instrument.previousClose,
                previousClose: instrument.previousClose
            )
        }
    }

    // MARK: Lifecycle

    func start() {
        guard pollTask == nil else { return }
        pollTask = Task { [weak self] in
            await self?.pollLoop()
        }
    }

    func stop() {
        pollTask?.cancel()
        pollTask = nil
        stopSimulation()
    }

    // MARK: Accessors

    func lastPrice(for symbol: String) -> Double {
        quotes[symbol]?.lastPrice
            ?? SeedData.instrument(for: symbol)?.previousClose
            ?? 0
    }

    func quote(for symbol: String) -> Quote? { quotes[symbol] }

    func previousClose(for symbol: String) -> Double {
        quotes[symbol]?.previousClose
            ?? SeedData.instrument(for: symbol)?.previousClose
            ?? 0
    }

    // MARK: Polling

    private func pollLoop() async {
        while !Task.isCancelled {
            let updated = await refreshOnce()
            if updated > 0 {
                isLive = true
                stopSimulation()
            } else if !isLive {
                // Never got real data yet — keep the UI alive with a simulation.
                startSimulation()
            }
            try? await Task.sleep(nanoseconds: UInt64(refreshInterval * 1_000_000_000))
        }
    }

    /// Fetch all symbols concurrently. Returns how many updated successfully.
    private func refreshOnce() async -> Int {
        await withTaskGroup(of: Quote?.self) { group in
            for instrument in SeedData.instruments {
                group.addTask { await Self.fetchQuote(symbol: instrument.symbol) }
            }
            var count = 0
            for await quote in group {
                if let quote {
                    quotes[quote.symbol] = quote
                    count += 1
                }
            }
            return count
        }
    }

    /// Fetch a single quote from Yahoo Finance. Returns nil on any failure.
    nonisolated private static func fetchQuote(symbol: String) async -> Quote? {
        let yahooSymbol = "\(symbol).NS"
        guard let url = URL(string:
            "https://query1.finance.yahoo.com/v8/finance/chart/\(yahooSymbol)?interval=1d&range=1d")
        else { return nil }

        var request = URLRequest(url: url)
        // A browser-like UA reduces the chance of being rate-limited/blocked.
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 8

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return nil
            }
            let decoded = try JSONDecoder().decode(YahooChartResponse.self, from: data)
            guard let meta = decoded.chart.result?.first?.meta,
                  let price = meta.regularMarketPrice else { return nil }
            let prevClose = meta.chartPreviousClose
                ?? meta.previousClose
                ?? SeedData.instrument(for: symbol)?.previousClose
                ?? price
            return Quote(symbol: symbol, lastPrice: price, previousClose: prevClose)
        } catch {
            return nil
        }
    }

    // MARK: Simulated fallback (offline / blocked)

    private func startSimulation() {
        guard simulationTimer == nil else { return }
        simulationTimer = Timer.publish(every: 1.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.simulateTick() }
    }

    private func stopSimulation() {
        simulationTimer?.cancel()
        simulationTimer = nil
    }

    private func simulateTick() {
        for (symbol, quote) in quotes {
            let prev = quote.previousClose
            let drift = (prev - quote.lastPrice) * 0.02
            let noise = quote.lastPrice * Double.random(in: -0.0015...0.0015)
            var updated = quote
            updated.lastPrice = ((quote.lastPrice + drift + noise) * 100).rounded() / 100
            quotes[symbol] = updated
        }
    }
}

// MARK: - Yahoo Finance response models

private struct YahooChartResponse: Decodable {
    let chart: Chart
    struct Chart: Decodable {
        let result: [Result]?
    }
    struct Result: Decodable {
        let meta: Meta
    }
    struct Meta: Decodable {
        let regularMarketPrice: Double?
        let previousClose: Double?
        let chartPreviousClose: Double?
    }
}

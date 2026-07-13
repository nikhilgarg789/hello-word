import Foundation

/// A fixed portfolio position. Quantity and average buy price are static (as if
/// the shares were bought earlier); the live P&L is derived from the current
/// market price supplied by `MarketDataService`.
struct Holding: Identifiable, Hashable {
    let id = UUID()
    let symbol: String
    let name: String
    let exchange: String
    /// Number of shares held.
    let quantity: Int
    /// Average price paid per share.
    let averagePrice: Double

    /// Total amount originally invested.
    var invested: Double { averagePrice * Double(quantity) }

    /// Current market value at the given last-traded price.
    func currentValue(ltp: Double) -> Double { ltp * Double(quantity) }

    /// Overall profit / loss at the given last-traded price.
    func pnl(ltp: Double) -> Double { (ltp - averagePrice) * Double(quantity) }

    /// Overall P&L as a percentage of the invested amount.
    func pnlPercent(ltp: Double) -> Double {
        guard invested != 0 else { return 0 }
        return (pnl(ltp: ltp) / invested) * 100
    }

    /// Day's change contribution: (ltp - prevClose) * qty.
    func dayPnl(ltp: Double, previousClose: Double) -> Double {
        (ltp - previousClose) * Double(quantity)
    }
}

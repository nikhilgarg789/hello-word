import Foundation

/// Static seed data for the demo: the universe of instruments, the watchlist,
/// and the fixed portfolio holdings.
enum SeedData {

    /// All instruments the app knows about (indexed by symbol elsewhere).
    static let instruments: [Instrument] = [
        Instrument(symbol: "RELIANCE",   name: "Reliance Industries",   exchange: "NSE", previousClose: 2945.60),
        Instrument(symbol: "TCS",        name: "Tata Consultancy Serv", exchange: "NSE", previousClose: 3902.10),
        Instrument(symbol: "INFY",       name: "Infosys",               exchange: "NSE", previousClose: 1648.75),
        Instrument(symbol: "HDFCBANK",   name: "HDFC Bank",             exchange: "NSE", previousClose: 1683.30),
        Instrument(symbol: "ICICIBANK",  name: "ICICI Bank",            exchange: "NSE", previousClose: 1251.45),
        Instrument(symbol: "SBIN",       name: "State Bank of India",   exchange: "NSE", previousClose: 831.20),
        Instrument(symbol: "TATAMOTORS", name: "Tata Motors",           exchange: "NSE", previousClose: 988.65),
        Instrument(symbol: "BHARTIARTL", name: "Bharti Airtel",         exchange: "NSE", previousClose: 1402.90),
        Instrument(symbol: "ITC",        name: "ITC",                   exchange: "NSE", previousClose: 434.55),
        Instrument(symbol: "WIPRO",      name: "Wipro",                 exchange: "NSE", previousClose: 462.10),
    ]

    /// The default watchlist (symbols shown on the first tab).
    static let watchlistSymbols: [String] = [
        "RELIANCE", "TCS", "INFY", "HDFCBANK", "ICICIBANK",
        "SBIN", "TATAMOTORS", "BHARTIARTL", "ITC", "WIPRO",
    ]

    /// Fixed portfolio positions. P&L is computed live against market prices.
    static let holdings: [Holding] = [
        Holding(symbol: "RELIANCE",   name: "Reliance Industries",   exchange: "NSE", quantity: 10, averagePrice: 2802.40),
        Holding(symbol: "TCS",        name: "Tata Consultancy Serv", exchange: "NSE", quantity: 5,  averagePrice: 3610.00),
        Holding(symbol: "INFY",       name: "Infosys",               exchange: "NSE", quantity: 20, averagePrice: 1502.15),
        Holding(symbol: "HDFCBANK",   name: "HDFC Bank",             exchange: "NSE", quantity: 15, averagePrice: 1598.80),
        Holding(symbol: "TATAMOTORS", name: "Tata Motors",           exchange: "NSE", quantity: 25, averagePrice: 851.30),
        Holding(symbol: "ITC",        name: "ITC",                   exchange: "NSE", quantity: 40, averagePrice: 448.90),
    ]

    /// Lookup helper.
    static func instrument(for symbol: String) -> Instrument? {
        instruments.first { $0.symbol == symbol }
    }
}

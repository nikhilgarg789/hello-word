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
        // Portfolio holdings (fetched for live prices; may not all resolve on Yahoo).
        Instrument(symbol: "TMPV",       name: "Tata Motors Pass. Veh.", exchange: "NSE", previousClose: 245.00),
        Instrument(symbol: "TMCV",       name: "Tata Motors Comm. Veh.", exchange: "NSE", previousClose: 130.00),
        Instrument(symbol: "JIOFIN",     name: "Jio Financial Services", exchange: "NSE", previousClose: 320.00),
    ]

    /// The default watchlist (symbols shown on the first tab).
    static let watchlistSymbols: [String] = [
        "RELIANCE", "TCS", "INFY", "HDFCBANK", "ICICIBANK",
        "SBIN", "TATAMOTORS", "BHARTIARTL", "ITC", "WIPRO",
    ]

    /// Fixed portfolio positions. P&L is computed live against market prices.
    static let holdings: [Holding] = [
        Holding(symbol: "TMPV",     name: "Tata Motors Pass. Veh.", exchange: "NSE", quantity: 5000, averagePrice: 210.00),
        Holding(symbol: "TMCV",     name: "Tata Motors Comm. Veh.", exchange: "NSE", quantity: 5000, averagePrice: 120.00),
        Holding(symbol: "RELIANCE", name: "Reliance Industries",    exchange: "NSE", quantity: 400,  averagePrice: 840.00),
        Holding(symbol: "JIOFIN",   name: "Jio Financial Services", exchange: "NSE", quantity: 200,  averagePrice: 230.00),
    ]

    /// Lookup helper.
    static func instrument(for symbol: String) -> Instrument? {
        instruments.first { $0.symbol == symbol }
    }
}

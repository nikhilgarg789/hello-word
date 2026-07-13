# KiteClone — a Kite by Zerodha look-alike (iOS / SwiftUI)

A demo iOS app that mimics the look and feel of **Kite by Zerodha**:

- **Dummy login experience** — Kite's two-step flow (User ID + password → 6-digit PIN). Any values are accepted; nothing leaves the device.
- **Watchlist** — a list of Indian equities (RELIANCE, TCS, INFY, HDFCBANK, …) with **live-updating** last-traded prices, day change and % change, colored green/red.
- **Portfolio** — a **fixed set of holdings** (quantity + average buy price). Invested value, current value, day's P&L and total P&L are all **computed live from the current prices**, so profit/loss changes in real time.
- **Account** — profile summary and logout.

> This is a UI/UX clone for learning and demo purposes. It is **not** affiliated with Zerodha, and it does not connect to any brokerage or place real orders.

## Requirements

- **Xcode 16** or newer (the project uses file-system-synchronized groups)
- iOS 17.0+ simulator or device

## Run it

1. Open `KiteClone.xcodeproj` in Xcode.
2. Select the **KiteClone** scheme and an iPhone simulator (e.g. iPhone 15).
3. Press **⌘R**.

At the login screen, type any User ID and password, tap **Login**, enter any 6 digits, and you're in.

## How the "live" prices work

There's no brokerage API key required. `MarketDataService` (`KiteClone/Services/MarketDataService.swift`)
generates prices with a small, mean-reverting random walk around each stock's
previous close, publishing updates a few times per second via Combine. Every
view observes it, so the watchlist and the portfolio P&L move on their own.

### Wiring in real market data

Replace the body of `MarketDataService.tick()` (or the timer entirely) with a
network call that updates `quotes[symbol]?.lastPrice` from a real quotes API
(e.g. the Kite Connect API or any market-data provider). The rest of the UI —
including all P&L math — will update automatically because it's driven off the
published `quotes` dictionary.

## Project structure

```
KiteClone/
  KiteCloneApp.swift        App entry + root (login vs. main) switch
  Theme/Theme.swift         Colors, formatters, hex helper
  Models/                   Instrument, Quote, Holding
  Services/
    SeedData.swift          Instruments, watchlist, fixed holdings
    MarketDataService.swift Live (simulated) price ticker
    SessionStore.swift      Dummy auth state
  Views/
    Login/                  CredentialsView, PinView
    Main/MainTabView.swift  Bottom tab bar (Watchlist/Orders/Portfolio/Bids/Account)
    Watchlist/              Watchlist + instrument detail
    Portfolio/              Portfolio summary + holding rows (live P&L)
    Orders/, Account/       Supporting tabs
```

## Customizing the portfolio & watchlist

Edit `KiteClone/Services/SeedData.swift`:

- `instruments` — the universe of stocks and their previous-close reference prices.
- `watchlistSymbols` — which symbols show on the Watchlist tab.
- `holdings` — your fixed positions (symbol, quantity, average price). P&L is derived automatically.

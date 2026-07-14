# KiteClone — a Kite by Zerodha look-alike (iOS / SwiftUI)

A demo iOS app that mimics the look and feel of **Kite by Zerodha**:

- **Face ID login** — the app opens on a Face ID / Touch ID screen and logs you in on a match, with a User ID + password fallback. Any credentials are accepted; nothing leaves the device.
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

Face ID prompts automatically. If you skip it, type any User ID and password and tap **Login** — you're straight in (no PIN step).

### Face ID auto-login

The app opens on a **Face ID / Touch ID** screen and prompts automatically
(like Kite). On a successful match it logs you straight in; otherwise use
**"Login with User ID instead."** It uses Apple's `LocalAuthentication`, so it's
real biometric auth.

**To test Face ID in the Simulator:**
1. Simulator menu: **Features → Face ID → Enrolled** (tick it).
2. Run the app. When the Face ID sheet appears, choose
   **Features → Face ID → Matching Face** to approve (or **Non-matching Face**
   to see it fail).

On a physical iPhone it uses the device's real Face ID / Touch ID.

## How the "live" prices work

Prices come from **Yahoo Finance's free, keyless quote endpoint** — no API key
or account needed. `MarketDataService` (`KiteClone/Services/MarketDataService.swift`)
polls `https://query1.finance.yahoo.com/v8/finance/chart/<SYMBOL>.NS` every few
seconds for each stock (NSE symbols map to Yahoo by appending `.NS`, e.g.
`RELIANCE.NS`), reads the latest price and previous close, and publishes them via
Combine. Every view observes it, so the watchlist and portfolio P&L update on
their own. A small **"live" / "sim"** badge on the watchlist shows whether real
data is flowing.

If the network is unavailable or Yahoo can't be reached, the service
automatically falls back to a small simulated random walk so the UI never looks
frozen.

Notes:
- Yahoo quotes are typically delayed ~15 minutes and are unofficial (the
  endpoint can rate-limit or change). Fine for a demo; not for real trading.
- Outside NSE market hours (09:15–15:30 IST) prices are the last close, so they
  won't move much — that's expected.

### Wiring in a different data source

Replace `MarketDataService.fetchQuote(symbol:)` with a call to your provider of
choice (Kite Connect, a paid market-data API, etc.) that returns last price and
previous close. The rest of the UI — including all P&L math — updates
automatically because it's driven off the published `quotes` dictionary.

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
    Login/                  BiometricLoginView, CredentialsView
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

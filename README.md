# FX1 – Custom Forex AOS for MetaTrader 5

An **Automated Order System (AOS)** for forex trading on the MetaTrader 5 platform, written in **MQL5**.

---

## Strategy overview

| Layer | Tool | Purpose |
|---|---|---|
| Trend filter | Fast EMA + Slow EMA | Only trade in the direction of the dominant trend |
| Entry signal | RSI + Stochastic crossover | Confirm pullback exhaustion before entering |
| Stop-loss | ATR × multiplier | Volatility-adaptive risk per trade |
| Take-profit | ATR × multiplier | Volatility-adaptive reward target |
| Position size | % of balance / SL distance | Fixed-fraction money management |
| Session filter | Configurable hours | Avoid low-liquidity periods |
| Spread filter | Max pips | Avoid entering during wide-spread conditions |

### Entry rules

**BUY**
1. Fast EMA > Slow EMA (uptrend)
2. RSI(14) crossed back above the oversold level (< 55)
3. Stochastic %K crossed above %D while still below overbought

**SELL**
1. Fast EMA < Slow EMA (downtrend)
2. RSI(14) crossed back below the overbought level (> 45)
3. Stochastic %K crossed below %D while still above oversold

### Exit rules
- The position is closed when the opposite entry signal fires (signal reversal)
- The hard TP/SL placed at order entry serves as a safety net

---

## File structure

```
MQL5/
├── Experts/
│   └── FX1/
│       └── FX1.mq5          ← Main Expert Advisor (compile & attach to chart)
└── Include/
    └── FX1/
        ├── Indicators.mqh   ← MA / RSI / ATR / Stochastic wrappers
        ├── RiskManager.mqh  ← Lot-size calculation (% risk model)
        └── TradeManager.mqh ← Order open / close / modify helpers
```

---

## Installation

1. Copy the entire `MQL5/` folder into your MetaTrader 5 **data folder**  
   (`Tools → Open Data Folder`).
2. In MetaEditor, open `MQL5/Experts/FX1/FX1.mq5` and press **Compile** (F7).
3. In the MT5 terminal, drag **FX1** from the Navigator onto any forex chart.
4. Enable **Algo Trading** (the green button in the toolbar).

---

## Input parameters

| Parameter | Default | Description |
|---|---|---|
| `MagicNumber` | 20240001 | Unique ID to distinguish EA orders |
| `TradeComment` | "FX1" | Comment attached to every order |
| `FastMAPeriod` | 50 | Period of the fast EMA |
| `SlowMAPeriod` | 200 | Period of the slow EMA |
| `MAMethod` | EMA | MA calculation method |
| `RSIPeriod` | 14 | RSI look-back period |
| `RSIOversold` | 30 | RSI level considered oversold |
| `RSIOverbought` | 70 | RSI level considered overbought |
| `StochK` | 5 | Stochastic %K period |
| `StochD` | 3 | Stochastic %D smoothing |
| `StochSlowing` | 3 | Stochastic slowing |
| `StochOversold` | 20 | Stochastic oversold level |
| `StochOverbought` | 80 | Stochastic overbought level |
| `ATRPeriod` | 14 | ATR look-back period |
| `SLMultiplier` | 1.5 | ATR × multiplier = stop-loss distance |
| `TPMultiplier` | 2.5 | ATR × multiplier = take-profit distance |
| `RiskPercent` | 1.0 | Maximum risk per trade (% of balance) |
| `MaxSpreadPips` | 3.0 | Skip entry if spread exceeds this value |
| `SessionStartHour` | 7 | Trading session start (server time, 0–23) |
| `SessionEndHour` | 20 | Trading session end (server time, 0–23) |

---

## Back-testing in Strategy Tester

1. Open **Strategy Tester** (`Ctrl+R`).
2. Select **Expert Advisor → FX1**.
3. Choose your symbol (e.g. EURUSD), timeframe (H1 recommended), and date range.
4. Set **Modelling** to *Every tick based on real ticks* for highest fidelity.
5. Run optimisation over `SLMultiplier`, `TPMultiplier`, and `RiskPercent` to find the best settings for your instrument.

---

## Risk disclaimer

This software is provided for educational and research purposes only. Past performance in back-tests does not guarantee future results. Always test thoroughly on a **demo account** before using real money.

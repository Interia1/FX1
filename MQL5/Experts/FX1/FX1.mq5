//+------------------------------------------------------------------+
//|                                                          FX1.mq5 |
//|                                    FX1 – Custom Forex AOS for MT5 |
//|                                                                  |
//|  Strategy overview                                               |
//|  ─────────────────                                               |
//|  • Trend filter  : Fast EMA above/below Slow EMA                |
//|  • Entry signal  : RSI leaving oversold/overbought zone AND      |
//|                    Stochastic %K/%D crossover in the same        |
//|                    direction as the trend                        |
//|  • Stop-loss     : ATR × SL multiplier below/above entry        |
//|  • Take-profit   : ATR × TP multiplier above/below entry        |
//|  • Position size : Fixed % risk of account balance              |
//|  • One position  : at most one open trade per symbol at a time  |
//|                                                                  |
//|  All parameters are exposed as input variables so the EA can be |
//|  optimised in MT5 Strategy Tester without recompilation.        |
//+------------------------------------------------------------------+
#property copyright "FX1"
#property version   "1.00"
#property strict

#include <FX1\Indicators.mqh>
#include <FX1\RiskManager.mqh>
#include <FX1\TradeManager.mqh>

//====================================================================
//  Input parameters
//====================================================================

//--- General
input ulong  MagicNumber    = 20240001;      // Magic number
input string TradeComment   = "FX1";         // Order comment

//--- Trend filter – Moving Averages
input int    FastMAPeriod   = 50;            // Fast EMA period
input int    SlowMAPeriod   = 200;           // Slow EMA period
input ENUM_MA_METHOD MAMethod = MODE_EMA;    // MA method

//--- Entry confirmation – RSI
input int    RSIPeriod      = 14;            // RSI period
input double RSIOversold    = 30.0;          // RSI oversold threshold
input double RSIOverbought  = 70.0;          // RSI overbought threshold

//--- Entry confirmation – Stochastic
input int    StochK         = 5;             // Stochastic %K period
input int    StochD         = 3;             // Stochastic %D smoothing
input int    StochSlowing   = 3;             // Stochastic slowing
input double StochOversold  = 20.0;          // Stochastic oversold level
input double StochOverbought= 80.0;          // Stochastic overbought level

//--- ATR-based SL / TP
input int    ATRPeriod      = 14;            // ATR period
input double SLMultiplier   = 1.5;           // ATR multiplier for stop-loss
input double TPMultiplier   = 2.5;           // ATR multiplier for take-profit

//--- Risk management
input double RiskPercent    = 1.0;           // Risk per trade (% of balance)
input double MaxSpreadPips  = 3.0;           // Maximum allowed spread in pips

//--- Trading session filter (server time, hour 0–23; -1 = disabled)
input int    SessionStartHour = 7;           // Session start hour
input int    SessionEndHour   = 20;          // Session end hour

//====================================================================
//  Global objects
//====================================================================
CMovingAverage g_fastMA, g_slowMA;
CRSI           g_rsi;
CATR           g_atr;
CStochastic    g_stoch;
CTradeManager* g_trade = NULL;

string g_symbol;
ENUM_TIMEFRAMES g_tf;

//====================================================================
//  OnInit
//====================================================================
int OnInit()
{
   g_symbol = Symbol();
   g_tf     = Period();

   //--- Sanity checks
   if(FastMAPeriod >= SlowMAPeriod)
   {
      Alert("FX1: FastMAPeriod must be smaller than SlowMAPeriod.");
      return INIT_PARAMETERS_INCORRECT;
   }

   //--- Initialise indicators
   if(!g_fastMA.Init(g_symbol, g_tf, FastMAPeriod, 0, MAMethod, PRICE_CLOSE) ||
      !g_slowMA.Init(g_symbol, g_tf, SlowMAPeriod, 0, MAMethod, PRICE_CLOSE) ||
      !g_rsi.Init(g_symbol, g_tf, RSIPeriod, PRICE_CLOSE)                    ||
      !g_atr.Init(g_symbol, g_tf, ATRPeriod)                                 ||
      !g_stoch.Init(g_symbol, g_tf, StochK, StochD, StochSlowing,
                    MODE_SMA, STO_LOWHIGH))
   {
      Alert("FX1: Failed to initialise one or more indicators.");
      return INIT_FAILED;
   }

   //--- Trade manager
   g_trade = new CTradeManager(MagicNumber, TradeComment);

   Print("FX1 initialised on ", g_symbol, " ", EnumToString(g_tf));
   return INIT_SUCCEEDED;
}

//====================================================================
//  OnDeinit
//====================================================================
void OnDeinit(const int reason)
{
   g_fastMA.Release();
   g_slowMA.Release();
   g_rsi.Release();
   g_atr.Release();
   g_stoch.Release();

   if(g_trade != NULL) { delete g_trade; g_trade = NULL; }
}

//====================================================================
//  OnTick
//====================================================================
void OnTick()
{
   //--- Only act on a new bar to avoid multiple signals per candle
   static datetime lastBarTime = 0;
   datetime        currentBarTime = iTime(g_symbol, g_tf, 0);
   if(currentBarTime == lastBarTime) return;
   lastBarTime = currentBarTime;

   //--- Session filter
   if(!IsSessionAllowed()) return;

   //--- Spread filter
   if(!IsSpreadAllowed()) return;

   //--- Read indicator values on the just-closed bar (index 1)
   double fastMA_cur = g_fastMA.Value(1);
   double slowMA_cur = g_slowMA.Value(1);
   double fastMA_prev= g_fastMA.Value(2);
   double slowMA_prev= g_slowMA.Value(2);

   double rsi        = g_rsi.Value(1);
   double atr        = g_atr.Value(1);

   double stochK_cur = g_stoch.K(1);
   double stochD_cur = g_stoch.D(1);
   double stochK_prev= g_stoch.K(2);
   double stochD_prev= g_stoch.D(2);

   if(atr == 0) return;

   //--- Trend direction
   bool bullTrend = (fastMA_cur > slowMA_cur);
   bool bearTrend = (fastMA_cur < slowMA_cur);

   //--- Stochastic crossover signals
   bool stochBullCross = (stochK_prev < stochD_prev) && (stochK_cur > stochD_cur);
   bool stochBearCross = (stochK_prev > stochD_prev) && (stochK_cur < stochD_cur);

   //--- Composite entry signals
   bool buySignal  = bullTrend
                     && (rsi > RSIOversold && rsi < 55.0)
                     && stochBullCross
                     && (stochK_cur < StochOverbought);

   bool sellSignal = bearTrend
                     && (rsi < RSIOverbought && rsi > 45.0)
                     && stochBearCross
                     && (stochK_cur > StochOversold);

   //--- Check existing position
   int openPositions = g_trade.CountPositions(g_symbol);
   int currentDir    = g_trade.PositionDirection(g_symbol);

   //--- Exit on opposite signal
   if(openPositions > 0)
   {
      if(currentDir == POSITION_TYPE_BUY  && sellSignal) g_trade.CloseAll(g_symbol);
      if(currentDir == POSITION_TYPE_SELL && buySignal)  g_trade.CloseAll(g_symbol);
   }

   //--- Open new position
   if(openPositions == 0 || g_trade.CountPositions(g_symbol) == 0)
   {
      double slPips = AtrToPips(g_symbol, atr) * SLMultiplier;
      double tpPips = AtrToPips(g_symbol, atr) * TPMultiplier;
      double lots   = CalculateLotSize(g_symbol, slPips, RiskPercent);

      if(buySignal)
      {
         double ask = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
         double sl  = NormPrice(g_symbol, ask - atr * SLMultiplier);
         double tp  = NormPrice(g_symbol, ask + atr * TPMultiplier);
         g_trade.OpenBuy(g_symbol, lots, sl, tp);
      }
      else if(sellSignal)
      {
         double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
         double sl  = NormPrice(g_symbol, bid + atr * SLMultiplier);
         double tp  = NormPrice(g_symbol, bid - atr * TPMultiplier);
         g_trade.OpenSell(g_symbol, lots, sl, tp);
      }
   }
}

//====================================================================
//  Helper functions
//====================================================================

//--- Normalise a price to the symbol's tick size
double NormPrice(string symbol, double price)
{
   double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickSize == 0) return price;
   return NormalizeDouble(MathRound(price / tickSize) * tickSize,
                          (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
}

//--- Check whether current server time is within the allowed session
bool IsSessionAllowed()
{
   if(SessionStartHour < 0 || SessionEndHour < 0) return true;
   int hour = (int)TimeHour(TimeCurrent());
   if(SessionStartHour <= SessionEndHour)
      return (hour >= SessionStartHour && hour < SessionEndHour);
   //--- Handles overnight sessions (e.g. 22–6)
   return (hour >= SessionStartHour || hour < SessionEndHour);
}

//--- Check whether the current spread is within the allowed limit
bool IsSpreadAllowed()
{
   double point = SymbolInfoDouble(g_symbol, SYMBOL_POINT);
   int    digits= (int)SymbolInfoInteger(g_symbol, SYMBOL_DIGITS);
   double pipSize = (digits == 5 || digits == 3) ? point * 10.0 : point;
   if(pipSize == 0) return true;

   long   spreadPoints = SymbolInfoInteger(g_symbol, SYMBOL_SPREAD);
   double spreadPips   = spreadPoints * point / pipSize;
   return (spreadPips <= MaxSpreadPips);
}

//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                                    FX1 – Custom Forex AOS for MT5 |
//|                                                                  |
//|  Handles position sizing based on account risk percentage and    |
//|  ATR-based stop-loss distance.                                   |
//+------------------------------------------------------------------+
#pragma once

//--- Calculates lot size so that the risk per trade does not exceed
//    RiskPercent of the current account balance.
//    stopLossPips: distance to stop-loss in pips (positive value)
double CalculateLotSize(string symbol, double stopLossPips, double riskPercent)
{
   double balance      = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount   = balance * riskPercent / 100.0;

   double tickSize     = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double point        = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double lotStep      = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double minLot       = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot       = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);

   if(tickSize == 0 || tickValue == 0 || point == 0)
      return minLot;

   //--- Convert pip distance to monetary value per lot
   double pipValue = (point / tickSize) * tickValue;
   if(pipValue == 0)
      return minLot;

   double lots = riskAmount / (stopLossPips * pipValue);

   //--- Round down to lot step
   lots = MathFloor(lots / lotStep) * lotStep;
   lots = MathMax(minLot, MathMin(maxLot, lots));

   return NormalizeDouble(lots, 2);
}

//--- Converts ATR value (in price units) to pips for the given symbol
double AtrToPips(string symbol, double atrValue)
{
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits   = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   //--- For 5-digit and 3-digit (JPY) brokers, 1 pip = 10 points
   double pipSize = (digits == 5 || digits == 3) ? point * 10.0 : point;

   if(pipSize == 0)
      return 0;

   return atrValue / pipSize;
}

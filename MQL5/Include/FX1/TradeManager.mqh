//+------------------------------------------------------------------+
//|                                                  TradeManager.mqh |
//|                                    FX1 – Custom Forex AOS for MT5 |
//|                                                                  |
//|  Wrapper around CTrade for opening, modifying and closing        |
//|  market orders with built-in error logging.                      |
//+------------------------------------------------------------------+
#pragma once
#include <Trade\Trade.mqh>

class CTradeManager
{
private:
   CTrade  m_trade;
   ulong   m_magic;
   string  m_comment;

public:
   CTradeManager(ulong magic, string comment)
   {
      m_magic   = magic;
      m_comment = comment;
      m_trade.SetExpertMagicNumber(magic);
      m_trade.SetDeviationInPoints(10);
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   }

   //--- Open a BUY market order
   bool OpenBuy(string symbol, double lots, double sl, double tp)
   {
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      bool   ok  = m_trade.Buy(lots, symbol, ask, sl, tp, m_comment);
      if(!ok)
         Print("OpenBuy failed: ", m_trade.ResultRetcodeDescription(),
               " symbol=", symbol, " lots=", lots);
      return ok;
   }

   //--- Open a SELL market order
   bool OpenSell(string symbol, double lots, double sl, double tp)
   {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      bool   ok  = m_trade.Sell(lots, symbol, bid, sl, tp, m_comment);
      if(!ok)
         Print("OpenSell failed: ", m_trade.ResultRetcodeDescription(),
               " symbol=", symbol, " lots=", lots);
      return ok;
   }

   //--- Close all positions for the symbol that match our magic number
   void CloseAll(string symbol)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != symbol) continue;
         if((ulong)PositionGetInteger(POSITION_MAGIC) != m_magic) continue;
         if(!m_trade.PositionClose(ticket))
            Print("CloseAll failed: ", m_trade.ResultRetcodeDescription(),
                  " ticket=", ticket);
      }
   }

   //--- Modify SL / TP of all open positions for the symbol
   void ModifyAll(string symbol, double newSL, double newTP)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != symbol) continue;
         if((ulong)PositionGetInteger(POSITION_MAGIC) != m_magic) continue;
         m_trade.PositionModify(ticket, newSL, newTP);
      }
   }

   //--- Return number of open positions for this symbol & magic
   int CountPositions(string symbol)
   {
      int count = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != symbol) continue;
         if((ulong)PositionGetInteger(POSITION_MAGIC) != m_magic) continue;
         count++;
      }
      return count;
   }

   //--- Return direction of first open position (ORDER_TYPE_BUY / ORDER_TYPE_SELL / -1)
   int PositionDirection(string symbol)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != symbol) continue;
         if((ulong)PositionGetInteger(POSITION_MAGIC) != m_magic) continue;
         return (int)PositionGetInteger(POSITION_TYPE);
      }
      return -1;
   }
};

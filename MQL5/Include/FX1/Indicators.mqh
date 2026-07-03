//+------------------------------------------------------------------+
//|                                                    Indicators.mqh |
//|                                    FX1 – Custom Forex AOS for MT5 |
//|                                                                  |
//|  Thin wrappers around iMA, iRSI, iATR and iStochastic so that   |
//|  the main EA logic stays clean.                                  |
//+------------------------------------------------------------------+
#pragma once

//+------------------------------------------------------------------+
//| Moving-Average helper                                            |
//+------------------------------------------------------------------+
class CMovingAverage
{
private:
   int    m_handle;
   string m_symbol;
   ENUM_TIMEFRAMES m_tf;

public:
   CMovingAverage() : m_handle(INVALID_HANDLE) {}

   bool Init(string symbol, ENUM_TIMEFRAMES tf, int period,
             int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price)
   {
      m_symbol = symbol;
      m_tf     = tf;
      m_handle = iMA(symbol, tf, period, shift, method, price);
      return (m_handle != INVALID_HANDLE);
   }

   double Value(int bar = 0)
   {
      double buf[];
      if(CopyBuffer(m_handle, 0, bar, 1, buf) <= 0) return 0;
      return buf[0];
   }

   void Release() { if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle); }
};

//+------------------------------------------------------------------+
//| RSI helper                                                       |
//+------------------------------------------------------------------+
class CRSI
{
private:
   int m_handle;

public:
   CRSI() : m_handle(INVALID_HANDLE) {}

   bool Init(string symbol, ENUM_TIMEFRAMES tf, int period, ENUM_APPLIED_PRICE price)
   {
      m_handle = iRSI(symbol, tf, period, price);
      return (m_handle != INVALID_HANDLE);
   }

   double Value(int bar = 0)
   {
      double buf[];
      if(CopyBuffer(m_handle, 0, bar, 1, buf) <= 0) return 50;
      return buf[0];
   }

   void Release() { if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle); }
};

//+------------------------------------------------------------------+
//| ATR helper                                                       |
//+------------------------------------------------------------------+
class CATR
{
private:
   int m_handle;

public:
   CATR() : m_handle(INVALID_HANDLE) {}

   bool Init(string symbol, ENUM_TIMEFRAMES tf, int period)
   {
      m_handle = iATR(symbol, tf, period);
      return (m_handle != INVALID_HANDLE);
   }

   double Value(int bar = 0)
   {
      double buf[];
      if(CopyBuffer(m_handle, 0, bar, 1, buf) <= 0) return 0;
      return buf[0];
   }

   void Release() { if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle); }
};

//+------------------------------------------------------------------+
//| Stochastic helper                                                |
//+------------------------------------------------------------------+
class CStochastic
{
private:
   int m_handle;

public:
   CStochastic() : m_handle(INVALID_HANDLE) {}

   bool Init(string symbol, ENUM_TIMEFRAMES tf,
             int kPeriod, int dPeriod, int slowing,
             ENUM_MA_METHOD method, STO_PRICE price)
   {
      m_handle = iStochastic(symbol, tf, kPeriod, dPeriod, slowing, method, price);
      return (m_handle != INVALID_HANDLE);
   }

   //--- %K line (buffer 0)
   double K(int bar = 0)
   {
      double buf[];
      if(CopyBuffer(m_handle, 0, bar, 1, buf) <= 0) return 50;
      return buf[0];
   }

   //--- %D line (buffer 1)
   double D(int bar = 0)
   {
      double buf[];
      if(CopyBuffer(m_handle, 1, bar, 1, buf) <= 0) return 50;
      return buf[0];
   }

   void Release() { if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle); }
};

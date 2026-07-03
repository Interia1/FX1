#ifndef FX1_UNIT_CONVERSION_MODULE_MQH
#define FX1_UNIT_CONVERSION_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class CUnitConversionModule : public IUnitConverter
{
public:
   bool RefreshSymbolContext(const string symbol) override
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      return (point > 0.0 && digits >= 0);
   }

   double PointsToPrice(const string symbol, const double points) override
   {
      return points * SymbolInfoDouble(symbol, SYMBOL_POINT);
   }

   double PriceToPoints(const string symbol, const double price_delta) override
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      if(point <= 0.0)
         return 0.0;
      return price_delta / point;
   }

   double NormalizePrice(const string symbol, const double price) override
   {
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      return NormalizeDouble(price, digits);
   }

   double NormalizeVolume(const string symbol, const double volume) override
   {
      double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      double clamped = MathMax(min_lot, MathMin(max_lot, volume));
      if(step <= 0.0)
         return clamped;

      double steps = MathFloor(clamped / step);
      return steps * step;
   }

   double SpreadInPoints(const string symbol) override
   {
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      return PriceToPoints(symbol, ask - bid);
   }

   int SlippageToDeviationPoints(const int slippage_points) override
   {
      return (slippage_points < 0) ? 0 : slippage_points;
   }
};

#endif

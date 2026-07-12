#ifndef FX1_POSITION_MODULE_MQH
#define FX1_POSITION_MODULE_MQH

#include <FX1/Core/Contracts.mqh>
#include <Trade/Trade.mqh>

class CPositionModule : public IPositionManager
{
private:
   CTrade m_trade;

   string PartialKey(const long magic, const ulong ticket)
   {
      return "FX1_PARTIAL_" + (string)magic + "_" + (string)ticket;
   }

   double NormalizeVolumeFloor(const string symbol, const double volume)
   {
      double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      if(step <= 0.0)
         return MathMax(min_lot, MathMin(max_lot, volume));

      double clamped = MathMax(min_lot, MathMin(max_lot, volume));
      double steps = MathFloor(clamped / step);
      return steps * step;
   }

   void ApplyTrailingStop(const SAppContext &ctx, const SMarketSnapshot &snapshot)
   {
      if(!ctx.settings.trailing_enabled)
         return;

      if(!PositionSelect(ctx.symbol))
         return;

      long magic = PositionGetInteger(POSITION_MAGIC);
      if(magic != ctx.settings.magic)
         return;

      long position_type = PositionGetInteger(POSITION_TYPE);
      double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
      double current_sl = PositionGetDouble(POSITION_SL);
      double current_tp = PositionGetDouble(POSITION_TP);
      double point = SymbolInfoDouble(ctx.symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(ctx.symbol, SYMBOL_DIGITS);
      if(point <= 0.0)
         return;

      double market_price = (position_type == POSITION_TYPE_BUY) ? snapshot.bid : snapshot.ask;
      double profit_points = (position_type == POSITION_TYPE_BUY)
                             ? ((market_price - open_price) / point)
                             : ((open_price - market_price) / point);

      if(profit_points < ctx.settings.trailing_start_points)
         return;

      double new_sl = current_sl;
      double lock_distance = ctx.settings.trailing_start_points * point;
      if(position_type == POSITION_TYPE_BUY)
      {
         double candidate = NormalizeDouble(market_price - lock_distance, digits);
         if(candidate >= snapshot.bid)
            return;
         if(current_sl <= 0.0 || (candidate - current_sl) >= (ctx.settings.trailing_step_points * point))
            new_sl = candidate;
      }
      else if(position_type == POSITION_TYPE_SELL)
      {
         double candidate = NormalizeDouble(market_price + lock_distance, digits);
         if(candidate <= snapshot.ask)
            return;
         if(current_sl <= 0.0 || (current_sl - candidate) >= (ctx.settings.trailing_step_points * point))
            new_sl = candidate;
      }

      if(new_sl > 0.0 && new_sl != current_sl)
      {
         m_trade.SetExpertMagicNumber(ctx.settings.magic);
         m_trade.SetDeviationInPoints(ctx.settings.slippage_points);
         m_trade.PositionModify(ctx.symbol, new_sl, current_tp);
      }
   }

   void ApplyPartialClose(const SAppContext &ctx, const SMarketSnapshot &snapshot)
   {
      if(!ctx.settings.partial_close_enabled)
         return;

      if(!PositionSelect(ctx.symbol))
         return;

      long magic = PositionGetInteger(POSITION_MAGIC);
      if(magic != ctx.settings.magic)
         return;

      ulong ticket = (ulong)PositionGetInteger(POSITION_TICKET);
      string key = PartialKey(ctx.settings.magic, ticket);
      if(GlobalVariableCheck(key))
         return;

      long position_type = PositionGetInteger(POSITION_TYPE);
      double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
      double position_volume = PositionGetDouble(POSITION_VOLUME);
      double point = SymbolInfoDouble(ctx.symbol, SYMBOL_POINT);
      if(point <= 0.0 || position_volume <= 0.0)
         return;

      double market_price = (position_type == POSITION_TYPE_BUY) ? snapshot.bid : snapshot.ask;
      double profit_points = (position_type == POSITION_TYPE_BUY)
                             ? ((market_price - open_price) / point)
                             : ((open_price - market_price) / point);

      double trigger_points = (double)ctx.settings.partial_close_trigger_points;
      if(ctx.settings.partial_close_trigger_mode == CIASTOCNY_SPUSTENIE_TP_PERCENT)
         trigger_points = (double)ctx.settings.take_profit_points * (ctx.settings.partial_close_trigger_tp_percent / 100.0);

      if(profit_points < trigger_points)
         return;

      double close_volume_raw = position_volume * (ctx.settings.partial_close_percent / 100.0);
      double close_volume = NormalizeVolumeFloor(ctx.symbol, close_volume_raw);
      double min_lot = SymbolInfoDouble(ctx.symbol, SYMBOL_VOLUME_MIN);
      double remaining = NormalizeVolumeFloor(ctx.symbol, position_volume - close_volume);

      if(close_volume < min_lot)
         return;
      if(remaining < min_lot)
         return;

      m_trade.SetExpertMagicNumber(ctx.settings.magic);
      m_trade.SetDeviationInPoints(ctx.settings.slippage_points);
      if(m_trade.PositionClosePartial(ctx.symbol, close_volume))
         GlobalVariableSet(key, (double)TimeCurrent());
   }

public:
   void ManageOpenPositions(const SAppContext &ctx, const SMarketSnapshot &snapshot) override
   {
      if(ctx.symbol == "" || snapshot.timestamp <= 0)
         return;

      ApplyTrailingStop(ctx, snapshot);
      ApplyPartialClose(ctx, snapshot);
   }
};

#endif

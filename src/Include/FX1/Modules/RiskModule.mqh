#ifndef FX1_RISK_MODULE_MQH
#define FX1_RISK_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class CRiskModule : public IRiskManager
{
private:
   IUnitConverter *m_converter;

public:
   CRiskModule(IUnitConverter *converter) : m_converter(converter) {}

   bool BuildDecision(const SAppContext &ctx,
                      const SMarketSnapshot &snapshot,
                      const SSignal &signal,
                      SRiskDecision &out_decision) override
   {
      out_decision.allowed = false;
      out_decision.volume = 0.0;
      out_decision.stop_loss = 0.0;
      out_decision.take_profit = 0.0;
      out_decision.reason = "invalid signal";

      if(signal.side == SIGNAL_NONE)
         return false;

      double entry = (signal.side == SIGNAL_BUY) ? snapshot.ask : snapshot.bid;
      double sl_delta = m_converter.PointsToPrice(ctx.symbol, ctx.settings.stop_loss_points);
      double tp_delta = m_converter.PointsToPrice(ctx.symbol, ctx.settings.take_profit_points);

      if(signal.side == SIGNAL_BUY)
      {
         out_decision.stop_loss = m_converter.NormalizePrice(ctx.symbol, entry - sl_delta);
         out_decision.take_profit = m_converter.NormalizePrice(ctx.symbol, entry + tp_delta);
      }
      else
      {
         out_decision.stop_loss = m_converter.NormalizePrice(ctx.symbol, entry + sl_delta);
         out_decision.take_profit = m_converter.NormalizePrice(ctx.symbol, entry - tp_delta);
      }

      double volume = ctx.settings.fixed_lot;
      if(!ctx.settings.use_fixed_lot)
      {
         double risk_money = AccountInfoDouble(ACCOUNT_BALANCE) * (ctx.settings.risk_percent / 100.0);
         double value_per_point_per_lot = 0.0;
         if(snapshot.tick_size > 0.0)
            value_per_point_per_lot = snapshot.tick_value * (snapshot.point / snapshot.tick_size);

         if(value_per_point_per_lot > 0.0)
         {
            double money_at_sl_one_lot = value_per_point_per_lot * (double)ctx.settings.stop_loss_points;
            if(money_at_sl_one_lot > 0.0)
               volume = risk_money / money_at_sl_one_lot;
         }
      }

      out_decision.volume = m_converter.NormalizeVolume(ctx.symbol, volume);
      out_decision.allowed = (out_decision.volume > 0.0);
      out_decision.reason = out_decision.allowed ? "ok" : "volume normalize failed";
      return out_decision.allowed;
   }
};

#endif

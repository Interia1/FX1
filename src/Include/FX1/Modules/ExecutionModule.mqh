#ifndef FX1_EXECUTION_MODULE_MQH
#define FX1_EXECUTION_MODULE_MQH

#include <Trade/Trade.mqh>
#include <FX1/Core/Contracts.mqh>

class CExecutionModule : public IExecution
{
private:
   CTrade m_trade;
   IUnitConverter *m_converter;

public:
   CExecutionModule(IUnitConverter *converter) : m_converter(converter) {}

   bool Execute(const SAppContext &ctx,
                const SMarketSnapshot &snapshot,
                const SSignal &signal,
                const SRiskDecision &decision,
                ulong &ticket,
                string &reason) override
   {
      ticket = 0;
      if(!decision.allowed)
      {
         reason = "risk rejected";
         return false;
      }

      m_trade.SetExpertMagicNumber(ctx.settings.magic);
      m_trade.SetDeviationInPoints(m_converter.SlippageToDeviationPoints(ctx.settings.slippage_points));

      bool ok = false;
      if(signal.side == SIGNAL_BUY)
      {
         ok = m_trade.Buy(decision.volume, ctx.symbol, snapshot.ask, decision.stop_loss, decision.take_profit, "FX1 buy");
      }
      else if(signal.side == SIGNAL_SELL)
      {
         ok = m_trade.Sell(decision.volume, ctx.symbol, snapshot.bid, decision.stop_loss, decision.take_profit, "FX1 sell");
      }

      if(!ok)
      {
         reason = "order send failed";
         return false;
      }

      ticket = m_trade.ResultOrder();
      reason = "ok";
      return true;
   }
};

#endif

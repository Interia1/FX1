#ifndef FX1_CHART_MODULE_MQH
#define FX1_CHART_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class CChartModule : public IChartOutput
{
private:
   string SignalLabel(const ESignalSide side)
   {
      if(side == SIGNAL_BUY)
         return "BUY";
      if(side == SIGNAL_SELL)
         return "SELL";
      return "NONE";
   }

public:
   void Render(const SAppContext &ctx,
               const SMarketSnapshot &snapshot,
               const SSignal &signal,
               const SRiskDecision &decision) override
   {
      string text = "FX1 | " + ctx.symbol + "\n" +
                    "Spread: " + DoubleToString(snapshot.spread_points, 1) + " bodov\n" +
                    "Signal: " + SignalLabel(signal.side) + "\n" +
                    "P1 vyhodnotenie: " + signal.reason + "\n" +
                    "Riziko/Exekucia: " + decision.reason + "\n" +
                    "Objem: " + DoubleToString(decision.volume, 2);

      // Future module outputs can be appended to this text block line by line.
      Comment(text);
   }
};

#endif

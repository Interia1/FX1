#ifndef FX1_CHART_MODULE_MQH
#define FX1_CHART_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class CChartModule : public IChartOutput
{
public:
   void Render(const SAppContext &ctx,
               const SMarketSnapshot &snapshot,
               const SSignal &signal,
               const SRiskDecision &decision) override
   {
      string text = "FX1 | " + ctx.symbol +
                    " | spread=" + DoubleToString(snapshot.spread_points, 1) +
                    " | signal=" + IntegerToString((int)signal.side) +
                    " | vol=" + DoubleToString(decision.volume, 2);
      Comment(text);
   }
};

#endif

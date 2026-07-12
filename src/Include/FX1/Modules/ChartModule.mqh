#ifndef FX1_CHART_MODULE_MQH
#define FX1_CHART_MODULE_MQH

#include <FX1/Core/Contracts.mqh>
#include <FX1/Modules/OutputFormatModule.mqh>

class CChartModule : public IChartOutput
{
private:
   COutputFormatModule m_output;

public:
   void Render(const SAppContext &ctx,
               const SMarketSnapshot &snapshot,
               const SSignal &signal,
               const SRiskDecision &decision) override
   {
      string text = m_output.Build(ctx, snapshot, signal, decision);
      Comment(text);
   }
};

#endif

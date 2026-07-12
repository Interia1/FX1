#ifndef FX1_OUTPUT_FORMAT_MODULE_MQH
#define FX1_OUTPUT_FORMAT_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class COutputFormatModule
{
private:
   string SignalLabel(const ESignalSide side) const
   {
      if(side == SIGNAL_BUY)
         return "BUY";
      if(side == SIGNAL_SELL)
         return "SELL";
      return "NONE";
   }

public:
   string Build(const SAppContext &ctx,
                const SMarketSnapshot &snapshot,
                const SSignal &signal,
                const SRiskDecision &decision) const
   {
      if(ctx.settings.output_mode == VYSTUP_VYPNUTY)
         return "";

      if(ctx.settings.output_mode == VYSTUP_STRUCNY)
      {
         string text = "FX1 | " + ctx.symbol;
         if(ctx.settings.output_show_signal)
            text += " | signal=" + SignalLabel(signal.side);
         if(ctx.settings.output_show_p1)
            text += " | P1=" + signal.reason;
         if(ctx.settings.output_show_spread)
            text += " | spread=" + DoubleToString(snapshot.spread_points, 1);
         return text;
      }

      string text = "FX1 | " + ctx.symbol;

      if(ctx.settings.output_show_spread)
         text += "\nSpread: " + DoubleToString(snapshot.spread_points, 1) + " bodov";
      if(ctx.settings.output_show_signal)
         text += "\nSignal: " + SignalLabel(signal.side);
      if(ctx.settings.output_show_p1)
         text += "\nP1 vyhodnotenie: " + signal.reason;
      if(ctx.settings.output_show_risk)
         text += "\nRiziko/Exekucia: " + decision.reason;
      if(ctx.settings.output_show_volume)
         text += "\nObjem: " + DoubleToString(decision.volume, 2);

      text += "\nVystupy modulov: priprava na P2/P3/ine";
      return text;
   }
};

#endif

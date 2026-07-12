#ifndef FX1_CHART_MODULE_MQH
#define FX1_CHART_MODULE_MQH

#include <FX1/Core/Contracts.mqh>
#include <FX1/Modules/OutputFormatModule.mqh>

class CChartModule : public IChartOutput
{
private:
   COutputFormatModule m_output;
   string m_name;

   long ResolveCorner(const int position)
   {
      if(position == PANEL_VPRAVO_HORE)
         return CORNER_RIGHT_UPPER;
      return CORNER_LEFT_UPPER;
   }

   void EnsurePanel(const long corner)
   {
      if(ObjectFind(0, m_name) < 0)
      {
         ObjectCreate(0, m_name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, m_name, OBJPROP_FONTSIZE, 9);
         ObjectSetString(0, m_name, OBJPROP_FONT, "Consolas");
      }

      ObjectSetInteger(0, m_name, OBJPROP_CORNER, corner);
      ObjectSetInteger(0, m_name, OBJPROP_XDISTANCE, 12);
      ObjectSetInteger(0, m_name, OBJPROP_YDISTANCE, 16);
      ObjectSetInteger(0, m_name, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, m_name, OBJPROP_BACK, false);
      ObjectSetInteger(0, m_name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, m_name, OBJPROP_SELECTABLE, false);
   }

public:
   CChartModule() : m_name("FX1_OUTPUT_PANEL") {}
   void Render(const SAppContext &ctx,
               const SMarketSnapshot &snapshot,
               const SSignal &signal,
               const SRiskDecision &decision) override
   {
      if(ctx.settings.output_panel_position == PANEL_NEUKAZOVAT ||
         ctx.settings.output_mode == VYSTUP_VYPNUTY)
      {
         ObjectDelete(0, m_name);
         return;
      }

      string text = m_output.Build(ctx, snapshot, signal, decision);
      EnsurePanel(ResolveCorner(ctx.settings.output_panel_position));
      ObjectSetString(0, m_name, OBJPROP_TEXT, text);
   }
};

#endif

#ifndef FX1_ENGINE_MQH
#define FX1_ENGINE_MQH

#include <FX1/Core/Contracts.mqh>

class CEngine
{
private:
   IUnitConverter *m_converter;
   ICondition *m_condition;
   ISafetyGate *m_safety;
   IRiskManager *m_risk;
   IExecution *m_execution;
   IPositionManager *m_positions;
   IChartOutput *m_chart;

public:
   CEngine(IUnitConverter *converter,
           ICondition *condition,
           ISafetyGate *safety,
           IRiskManager *risk,
           IExecution *execution,
           IPositionManager *positions,
           IChartOutput *chart)
   {
      m_converter = converter;
      m_condition = condition;
      m_safety = safety;
      m_risk = risk;
      m_execution = execution;
      m_positions = positions;
      m_chart = chart;
   }

   SMarketSnapshot BuildSnapshot(const string symbol)
   {
      SMarketSnapshot s;
      s.timestamp = TimeCurrent();
      s.symbol = symbol;
      s.bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      s.ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      s.point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      s.tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      s.tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      s.digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      s.spread_points = m_converter.SpreadInPoints(symbol);
      return s;
   }

   void OnTick(const SAppContext &ctx)
   {
      if(!m_converter.RefreshSymbolContext(ctx.symbol))
         return;

      SMarketSnapshot snapshot = BuildSnapshot(ctx.symbol);
      m_positions.ManageOpenPositions(ctx, snapshot);

      string safe_reason = "";
      if(!m_safety.AllowTrading(ctx, snapshot, safe_reason))
      {
         SSignal neutral_signal;
         neutral_signal.side = SIGNAL_NONE;
         neutral_signal.confidence = 0.0;
         neutral_signal.reason = safe_reason;

         SRiskDecision neutral_decision;
         neutral_decision.allowed = false;
         neutral_decision.volume = 0.0;
         neutral_decision.stop_loss = 0.0;
         neutral_decision.take_profit = 0.0;
         neutral_decision.reason = safe_reason;

         m_chart.Render(ctx, snapshot, neutral_signal, neutral_decision);
         return;
      }

      SSignal signal;
      signal.side = SIGNAL_NONE;
      signal.confidence = 0.0;
      signal.reason = "none";

      if(!m_condition.Evaluate(snapshot, signal))
         return;
      if(signal.side == SIGNAL_NONE)
         return;

      SRiskDecision decision;
      if(!m_risk.BuildDecision(ctx, snapshot, signal, decision))
      {
         m_chart.Render(ctx, snapshot, signal, decision);
         return;
      }

      ulong ticket = 0;
      string exec_reason = "";
      m_execution.Execute(ctx, snapshot, signal, decision, ticket, exec_reason);
      m_chart.Render(ctx, snapshot, signal, decision);
   }
};

#endif

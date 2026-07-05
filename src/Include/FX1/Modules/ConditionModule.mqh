#ifndef FX1_CONDITION_MODULE_MQH
#define FX1_CONDITION_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class CConditionModule : public ICondition
{
public:
   bool Evaluate(const SMarketSnapshot &snapshot, SSignal &out_signal) override
   {
      out_signal.side = SIGNAL_NONE;
      out_signal.confidence = 0.0;
      out_signal.reason = "no signal";

      if(snapshot.spread_points <= 0.0)
         return false;

      // Run once per new bar to keep behavior deterministic in tester.
      datetime bar_open_time = iTime(snapshot.symbol, PERIOD_CURRENT, 0);
      if(bar_open_time <= 0)
         return false;

      static datetime s_last_bar_open_time = 0;
      if(s_last_bar_open_time == bar_open_time)
         return false;
      s_last_bar_open_time = bar_open_time;

      double close1 = iClose(snapshot.symbol, PERIOD_CURRENT, 1);
      double close2 = iClose(snapshot.symbol, PERIOD_CURRENT, 2);
      double close3 = iClose(snapshot.symbol, PERIOD_CURRENT, 3);

      if(close1 <= 0.0 || close2 <= 0.0 || close3 <= 0.0)
         return false;

      if(close1 > close2 && close2 > close3)
      {
         out_signal.side = SIGNAL_BUY;
         out_signal.confidence = 0.55;
         out_signal.reason = "test momentum buy";
         return true;
      }

      if(close1 < close2 && close2 < close3)
      {
         out_signal.side = SIGNAL_SELL;
         out_signal.confidence = 0.55;
         out_signal.reason = "test momentum sell";
         return true;
      }

      return false;
   }
};

#endif

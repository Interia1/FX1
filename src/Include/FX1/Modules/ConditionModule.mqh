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

      // Placeholder baseline rule. Replace with strategy logic.
      if(snapshot.spread_points <= 0.0)
         return false;

      return false;
   }
};

#endif

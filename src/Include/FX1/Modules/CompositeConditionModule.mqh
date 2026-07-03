#ifndef FX1_COMPOSITE_CONDITION_MODULE_MQH
#define FX1_COMPOSITE_CONDITION_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class CCompositeConditionModule : public ICondition
{
private:
   ICondition *m_primary;
   ICondition *m_filter;

public:
   CCompositeConditionModule() : m_primary(NULL), m_filter(NULL) {}

   void SetPrimary(ICondition *condition)
   {
      m_primary = condition;
   }

   void SetFilter(ICondition *condition)
   {
      m_filter = condition;
   }

   bool Evaluate(const SMarketSnapshot &snapshot, SSignal &out_signal) override
   {
      if(m_primary == NULL)
         return false;

      SSignal primary_signal;
      primary_signal.side = SIGNAL_NONE;
      primary_signal.confidence = 0.0;
      primary_signal.reason = "primary not set";

      bool primary_ok = m_primary.Evaluate(snapshot, primary_signal);
      if(!primary_ok || primary_signal.side == SIGNAL_NONE)
         return false;

      if(m_filter == NULL)
      {
         out_signal = primary_signal;
         return true;
      }

      SSignal filter_signal;
      filter_signal.side = SIGNAL_NONE;
      filter_signal.confidence = 0.0;
      filter_signal.reason = "filter rejected";

      bool filter_ok = m_filter.Evaluate(snapshot, filter_signal);
      if(!filter_ok)
         return false;

      out_signal = primary_signal;
      out_signal.reason = primary_signal.reason + " + filter";
      return true;
   }
};

#endif

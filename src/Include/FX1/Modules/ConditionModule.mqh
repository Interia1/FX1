#ifndef FX1_CONDITION_MODULE_MQH
#define FX1_CONDITION_MODULE_MQH

#include <FX1/Core/Contracts.mqh>
#include <FX1/Config/DevSettings.mqh>
#include <FX1/Modules/Conditions/P1Condition.mqh>

class CConditionModule : public ICondition
{
private:
   SDevSettings m_dev;
   CP1Condition m_p1;

public:
   CConditionModule()
   {
      m_dev = DefaultDevSettings();
      m_p1.Configure(m_dev);
   }

   void Configure(const SDevSettings &dev)
   {
      m_dev = dev;
      m_p1.Configure(dev);
   }

   bool Evaluate(const SMarketSnapshot &snapshot, SSignal &out_signal) override
   {
      out_signal.side = SIGNAL_NONE;
      out_signal.confidence = 0.0;
      out_signal.reason = "no active condition";

      bool run_p1 = m_p1.IsEnabled();
      if(m_dev.condition_test_mode)
         run_p1 = (m_dev.single_condition_id == CONDITION_P1);

      if(!run_p1)
      {
         out_signal.reason = "P1 skipped by config";
         return false;
      }

      return m_p1.Evaluate(snapshot, out_signal);
   }
};

#endif

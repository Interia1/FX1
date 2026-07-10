#ifndef FX1_CONDITION_MODULE_MQH
#define FX1_CONDITION_MODULE_MQH

#include <FX1/Core/Contracts.mqh>
#include <FX1/Config/DevSettings.mqh>
#include <FX1/Modules/Conditions/P1Condition.mqh>
#include <FX1/Modules/Conditions/P2Condition.mqh>
#include <FX1/Modules/Conditions/P3Condition.mqh>

class CConditionModule : public ICondition
{
private:
   SDevSettings m_dev;
   CP1Condition m_p1;
   CP2Condition m_p2;
   CP3Condition m_p3;

   bool EvaluateSingle(const EConditionId id, const SMarketSnapshot &snapshot, SSignal &out_signal)
   {
      if(id == CONDITION_P1)
         return m_p1.Evaluate(snapshot, out_signal);
      if(id == CONDITION_P2)
         return m_p2.Evaluate(snapshot, out_signal);
      if(id == CONDITION_P3)
         return m_p3.Evaluate(snapshot, out_signal);

      out_signal.side = SIGNAL_NONE;
      out_signal.confidence = 0.0;
      out_signal.reason = "unknown condition id";
      return false;
   }

public:
   CConditionModule()
   {
      m_dev = DefaultDevSettings();
      m_p1.Configure(m_dev);
      m_p2.Configure(m_dev);
      m_p3.Configure(m_dev);
   }

   void Configure(const SDevSettings &dev)
   {
      m_dev = dev;
      m_p1.Configure(dev);
      m_p2.Configure(dev);
      m_p3.Configure(dev);
   }

   bool Evaluate(const SMarketSnapshot &snapshot, SSignal &out_signal) override
   {
      out_signal.side = SIGNAL_NONE;
      out_signal.confidence = 0.0;
      out_signal.reason = "no active condition";

      if(m_dev.condition_test_mode)
         return EvaluateSingle(m_dev.single_condition_id, snapshot, out_signal);

      if(m_p1.IsEnabled())
         return m_p1.Evaluate(snapshot, out_signal);
      if(m_p2.IsEnabled())
         return m_p2.Evaluate(snapshot, out_signal);
      if(m_p3.IsEnabled())
         return m_p3.Evaluate(snapshot, out_signal);

      out_signal.reason = "all conditions disabled";
      return false;
   }
};

#endif

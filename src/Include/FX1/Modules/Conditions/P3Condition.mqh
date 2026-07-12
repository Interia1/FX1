#ifndef FX1_P3_CONDITION_MQH
#define FX1_P3_CONDITION_MQH

#include <FX1/Config/DevSettings.mqh>
#include <FX1/Core/Types.mqh>

class CP3Condition
{
private:
   bool m_enabled;
   bool m_emit_signal;
   ESignalSide m_signal_side;

public:
   CP3Condition()
   {
      SDevSettings d = DefaultDevSettings();
      m_enabled = d.p3_enabled;
      m_emit_signal = d.p3_emit_signal;
      m_signal_side = d.p3_buy_signal ? SIGNAL_BUY : SIGNAL_SELL;
   }

   void Configure(const SDevSettings &dev)
   {
      m_enabled = dev.p3_enabled;
      m_emit_signal = dev.p3_emit_signal;
      m_signal_side = dev.p3_buy_signal ? SIGNAL_BUY : SIGNAL_SELL;
   }

   bool IsEnabled() const
   {
      return m_enabled;
   }

   bool Evaluate(const SMarketSnapshot &snapshot, SSignal &out_signal)
   {
      if(snapshot.timestamp <= 0)
         return false;
      out_signal.side = SIGNAL_NONE;
      out_signal.confidence = 0.0;

      if(!m_enabled)
      {
         out_signal.reason = "P3 disabled";
         return false;
      }

      out_signal.reason = "P3 TODO: logic not implemented yet";
      if(m_emit_signal)
         out_signal.side = m_signal_side;

      return false;
   }
};

#endif